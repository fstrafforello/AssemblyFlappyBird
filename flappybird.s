# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
	displayAddress:	.word	0x10008000
	keyboardAddress1: .word  0xffff0004
	keyboardAddress2: .word  0xffff0004
	
.text
	li $s2, 500		# initial time
	
	lw $t0, displayAddress	# $t0 stores the base address for the background 
	
	li $t1, 0x03f4fc	# $t1 stores the blue colour code
	li $t6, 0x42f54e	# $t6 stores the green colour code
	li $t8, 0xf5f242	# $t8 stores the yellow colour code

	li $t2, 4096		# number of pixels on screen
	
	li $t3, 10		# minimum number of pixels away pipe must be from top/bottom
	
	li $t5, 4		# size of one pixel
	
	add $v0, $t0, $t2
	la $t4, ($v0)

background:
	sw $t1, 0($t0)
	addu $t0, $t0, 4
	bne $t0, $t4, background
	lw $t0, displayAddress

bird: 
	addu $t0,$t0, 1300
	sw $t8, 0($t0)
	addi $s6, $t0, 0
	
	addu $t0, $t0, 8
	sw $t8, 0($t0)
	
	addu $t0, $t0, 120
	sw $t8, 0($t0)
	
	addu $t0, $t0, 4
	sw $t8, 0($t0)
	
	addu $t0, $t0, 4
	sw $t8, 0($t0)
	
	addu $t0, $t0, 4
	sw $t8, 0($t0)
	
	addu $t0, $t0, 116
	sw $t8, 0($t0)
	
	addu $t0, $t0, 8
	sw $t8, 0($t0)
	
	lw $t0, displayAddress

bird_2: 
	addu $t0,$t0, 1332
	sw $t8, 0($t0)
	addi $s7, $t0, 0
	
	addu $t0, $t0, 8
	sw $t8, 0($t0)
	
	addu $t0, $t0, 120
	sw $t8, 0($t0)
	
	addu $t0, $t0, 4
	sw $t8, 0($t0)
	
	addu $t0, $t0, 4
	sw $t8, 0($t0)
	
	addu $t0, $t0, 4
	sw $t8, 0($t0)
	
	addu $t0, $t0, 116
	sw $t8, 0($t0)
	
	addu $t0, $t0, 8
	sw $t8, 0($t0)
	
	lw $t0, displayAddress

initial_pipe:
	addi $a2, $a2, 1
	subi $s2, $s2, 5
	jal clean_old_pipe
	lw $t0, displayAddress
	
	jal random
	
	li $s0, 0		# counter of rows
	upper_pipe:			# loop to color 1 row
		addu $t0, $t0, 108
		addu $s1, $t0, 16
		jal color_one_row
		addi $s0, $s0, 1	# couter+1
		ble $s0, $a0, upper_pipe
	
	addi $s0, $s0, 10	# gap
	addu $t0, $t0, 1280
	li $a0, 32
	
	lower_pipe:		# loop to color 1 row
		addu $t0, $t0, 108
		addu $s1, $t0, 16
		jal color_one_row
		addi $s0, $s0, 1	# couter+1
		ble $s0, $a0, lower_pipe
	
	lw $t0, displayAddress

main:
	li $t9, 27		# total number of x-pixels - length of pipe
	add $s3, $t0, $t2
	while:
		jal shift_pipe
		jal shift_bird_down
		jal shift_bird_2_down
		jal sleep
		jal recive_input
		beq $s4, 102, shift_bird_up
		beq $s4, 106, shift_bird_2_up
		point_3:
		li $s4, 0
		li $a3, 0
		jal check_out_of_screen
		bne $a3, 16, end_screen
		jal check_pipe
		
		lw $v0, 0($t0)			# check if pixel is green
		beq $v0, $t6, choose_message
		
		j while

Exit:
	li $v0, 10		# terminate the program gracefully
	syscall

random:
	li $v0, 42		# 42 is system call code to generate random int
	li $a1, 16		# $a1 is where you set the upper bound
	syscall			# generated number will be at $a0
	jr $ra

color_one_row:
	sw $t6, 0($t0)
	addu $t0, $t0, 4
	ble $t0, $s1, color_one_row
	jr $ra

shift_pipe:
	beqz $t9, initial_pipe
	subi $t9, $t9, 1
	sll $t9, $t9, 2
	
	addu $t0, $t0, $t9
	
	color_column_green:
		addu $v0, $t0, 4
		lw $v1, 0($v0)
		lw $v0, 0($t0)
		bne $v0, $v1, color_green_pixel			# check if color is not the same in next pixel
		point:
			addu $t0, $t0, 128
			bltu $t0, $s3, color_column_green
	
	lw $t0, displayAddress
	
	addu $s5, $t0, $t2
	
	addu $t0, $t0, $t9
	addu $t0, $t0, 20
	
	color_column_blue:
		j color_blue_pixel
		point_2:
			addu $t0, $t0, 128
			blt $t0, $s5, color_column_blue
	
	srl $t9, $t9, 2
	lw $t0, displayAddress
	
	jr $ra

clean_old_pipe:
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	addu $t0, $t0, 128
	bne $t0, $t4, clean_old_pipe
	jr $ra

reset_t9:
	li $t9, 27

color_green_pixel:
	lw $v0, ($t0)			# check if pixel is yellow
	beq $v0, $t8, go_back
	
	addi $v1, $t0, 4		# check if next pixel is yellow
	lw $v0, ($v1)
	beq $v0, $t8, go_back
	
	sw $t6, 0($t0)
	go_back:
		j point

color_blue_pixel:
	lw $v0, ($t0)
	beq $v0, $t8, go_back_2
	sw $t1, 0($t0)
	go_back_2:
		j point_2
		
sleep:
	li $v0, 32
	la $a0, ($s2)
	syscall
	jr $ra
	
shift_bird_down:
	sw $t1, 264($s6)         
	sw $t8, 392($s6)
	
	sw $t1, 256($s6)         
	sw $t8, 384($s6)
	
	sw $t1, 140($s6)         
	sw $t8, 268($s6)
	
	sw $t1, 136($s6)         
	sw $t8, 264($s6)

	sw $t1, 132($s6)         
	sw $t8, 260($s6)
	
	sw $t1, 128($s6)         
	sw $t8, 256($s6)
	
	sw $t1, 8($s6)         
	sw $t8, 136($s6)
	
	sw $t1, 0($s6)         
	sw $t8, 128($s6)
	
	addi $s6, $s6, 128
	jr $ra

shift_bird_2_down:
	sw $t1, 264($s7)         
	sw $t8, 392($s7)
	
	sw $t1, 256($s7)         
	sw $t8, 384($s7)
	
	sw $t1, 140($s7)         
	sw $t8, 268($s7)
	
	sw $t1, 136($s7)         
	sw $t8, 264($s7)
	
	sw $t1, 132($s7)         
	sw $t8, 260($s7)
	
	sw $t1, 128($s7)         
	sw $t8, 256($s7)
	
	sw $t1, 8($s7)        
	sw $t8, 136($s7)
	
	sw $t1, 0($s7)         
	sw $t8, 128($s7)
	
	addi $s7, $s7, 128
	jr $ra
	
recive_input:
	li $t7, 0xffff0000
	rd_poll:
		lw $v0, 0($t7)
		andi $v0, $v0, 0x01
		
	beq $v0, $zero, point_3
	lw $s4, 4($t7)
	# last key code in $v0
	jr $ra

shift_bird_up:
	sw $t8, -384($s6)         
	sw $t1, 0($s6)
	
	sw $t8, -376($s6)         
	sw $t1, 8($s6)
	
	sw $t8, -256($s6)         
	sw $t1, 128($s6)
	
	sw $t8, -252($s6)         
	sw $t1, 132($s6)

	sw $t8, -248($s6)         
	sw $t1, 136($s6)
	
	sw $t8, -244($s6)         
	sw $t1, 140($s6)
	
	sw $t8, -128($s6)         
	sw $t1, 256($s6)
	
	sw $t8, -120($s6)         
	sw $t1, 264($s6)
	
	subi $s6, $s6, 384
	j point_3

shift_bird_2_up:
	sw $t8, -384($s7)         
	sw $t1, 0($s7)
	
	sw $t8, -376($s7)         
	sw $t1, 8($s7)
	
	sw $t8, -256($s7)         
	sw $t1, 128($s7)
	
	sw $t8, -252($s7)         
	sw $t1, 132($s7)

	sw $t8, -248($s7)         
	sw $t1, 136($s7)
	
	sw $t8, -244($s7)         
	sw $t1, 140($s7)
	
	sw $t8, -128($s7)         
	sw $t1, 256($s7)
	
	sw $t8, -120($s7)         
	sw $t1, 264($s7)
	
	subi $s7, $s7, 384
	j point_3
	

check_out_of_screen:
	
	lw $v0, ($t0)			# check if pixel is yellow
	beq $v0, $t8, increment 
	point_4:
	
	addu $t0, $t0, 4
	bne $t0, $t4, check_out_of_screen
	lw $t0, displayAddress
	jr $ra
	
increment:
	addi $a3, $a3, 1
	j point_4
	
end_screen:
	sw $t1, 0($t0)
	addu $t0, $t0, 4
	bne $t0, $t4, end_screen
	lw $t0, displayAddress
	
	addu $t0, $t0, 1816
	sw $t8, 0($t0)
	
	sw $t8, 32($t0)
	sw $t8, 36($t0)
	sw $t8, 40($t0)
	sw $t8, 48($t0)
	
	sw $t8, 128($t0)
	sw $t8, 160($t0)
	sw $t8, 176($t0)
	
	sw $t8, 256($t0)
	sw $t8, 260($t0)
	sw $t8, 264($t0)
	sw $t8, 272($t0)
	sw $t8, 280($t0)
	sw $t8, 288($t0)
	sw $t8, 292($t0)
	sw $t8, 296($t0)
	sw $t8, 304($t0)
	
	sw $t8, 384($t0)
	sw $t8, 392($t0)
	sw $t8, 400($t0)
	sw $t8, 408($t0)
	sw $t8, 416($t0)
	
	sw $t8, 512($t0)
	sw $t8, 516($t0)
	sw $t8, 520($t0)
	sw $t8, 528($t0)
	sw $t8, 532($t0)
	sw $t8, 536($t0)
	sw $t8, 544($t0)
	sw $t8, 548($t0)
	sw $t8, 552($t0)
	sw $t8, 560($t0)
	
	sw $t8, 664($t0)
	
	sw $t8, 784($t0)
	sw $t8, 788($t0)
	sw $t8, 792($t0)
	j Exit

check_pipe:
	lw $v0, -128($s6)			# check if pixel is green
	beq $v0, $t6, end_screen
	
	lw $v0, -120($s6)			# check if pixel is green
	beq $v0, $t6, end_screen

	lw $v0, 12($s6)			# check if pixel is green
	beq $v0, $t6, end_screen
	
	lw $v0, 144($s6)			# check if pixel is green
	beq $v0, $t6, end_screen
	
	lw $v0, 260($s6)			# check if pixel is green
	beq $v0, $t6, end_screen
	
	lw $v0, 268($s6)			# check if pixel is green
	beq $v0, $t6, end_screen
	
	lw $v0, 384($s6)			# check if pixel is green
	beq $v0, $t6, end_screen
	
	lw $v0, 392($s6)			# check if pixel is green
	beq $v0, $t6, end_screen
	
	lw $v0, -128($s7)			# check if pixel is green
	beq $v0, $t6, end_screen
	
	lw $v0, -120($s7)			# check if pixel is green
	beq $v0, $t6, end_screen
	
	lw $v0, 12($s7)			# check if pixel is green
	beq $v0, $t6, end_screen
	
	lw $v0, 144($s7)			# check if pixel is green
	beq $v0, $t6, end_screen
	
	lw $v0, 260($s7)			# check if pixel is green
	beq $v0, $t6, end_screen
	
	lw $v0, 268($s7)			# check if pixel is green
	beq $v0, $t6, end_screen
	
	lw $v0, 384($s7)			# check if pixel is green
	beq $v0, $t6, end_screen
	
	lw $v0, 392($s7)			# check if pixel is green
	beq $v0, $t6, end_screen
	jr $ra

choose_message:
	ble $a2, 10, message_1
	bgt $a2, 10, message_2

message_1:
	sw $t1, 0($t0)
	addu $t0, $t0, 4
	bne $t0, $t4, message_1
	lw $t0, displayAddress
	
	addu $t0, $t0, 1332
	
	sw $t8, 4($t0)
	sw $t8, 8($t0)
	sw $t8, 12($t0)
	sw $t8, 60($t0)
	sw $t8, 68($t0)
	sw $t8, 128($t0)
	sw $t8, 188($t0)
	sw $t8, 196($t0)
	sw $t8, 256($t0)
	sw $t8, 316($t0)
	sw $t8, 324($t0)
	sw $t8, 384($t0)
	sw $t8, 392($t0)
	sw $t8, 404($t0)
	sw $t8, 408($t0)
	sw $t8, 412($t0)
	sw $t8, 420($t0)
	sw $t8, 424($t0)
	sw $t8, 428($t0)
	sw $t8, 436($t0)
	sw $t8, 440($t0)
	sw $t8, 444($t0)
	sw $t8, 452($t0)
	sw $t8, 512($t0)
	sw $t8, 524($t0)
	sw $t8, 532($t0)
	sw $t8, 540($t0)
	sw $t8, 548($t0)
	sw $t8, 556($t0)
	sw $t8, 564($t0)
	sw $t8, 572($t0)
	sw $t8, 644($t0)
	sw $t8, 648($t0)
	sw $t8, 652($t0)
	sw $t8, 660($t0)
	sw $t8, 664($t0)
	sw $t8, 668($t0)
	sw $t8, 676($t0)
	sw $t8, 680($t0)
	sw $t8, 684($t0)
	sw $t8, 692($t0)
	sw $t8, 696($t0)
	sw $t8, 700($t0)
	sw $t8, 708($t0)
	
	lw $t0, displayAddress
	
	li $v0, 32
	la $a0, ($s2)
	syscall
	
	addu $t0, $t0, 1332
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 60($t0)
	sw $t1, 68($t0)
	sw $t1, 128($t0)
	sw $t1, 188($t0)
	sw $t1, 196($t0)
	sw $t1, 256($t0)
	sw $t1, 316($t0)
	sw $t1, 324($t0)
	sw $t1, 384($t0)
	sw $t1, 392($t0)
	sw $t1, 404($t0)
	sw $t1, 408($t0)
	sw $t1, 412($t0)
	sw $t1, 420($t0)
	sw $t1, 424($t0)
	sw $t1, 428($t0)
	sw $t1, 436($t0)
	sw $t1, 440($t0)
	sw $t1, 444($t0)
	sw $t1, 452($t0)
	sw $t1, 512($t0)
	sw $t1, 524($t0)
	sw $t1, 532($t0)
	sw $t1, 540($t0)
	sw $t1, 548($t0)
	sw $t1, 556($t0)
	sw $t1, 564($t0)
	sw $t1, 572($t0)
	sw $t1, 644($t0)
	sw $t1, 648($t0)
	sw $t1, 652($t0)
	sw $t1, 660($t0)
	sw $t1, 664($t0)
	sw $t1, 668($t0)
	sw $t1, 676($t0)
	sw $t1, 680($t0)
	sw $t1, 684($t0)
	sw $t1, 692($t0)
	sw $t1, 696($t0)
	sw $t1, 700($t0)
	sw $t1, 708($t0)
	
	lw $t0, displayAddress
	
	jr $ra

message_2:
	sw $t1, 0($t0)
	addu $t0, $t0, 4
	bne $t0, $t4, message_2
	lw $t0, displayAddress
	
	addu $t0, $t0, 1332
	
	sw $t8, 0($t0)
	sw $t8, 16($t0)
	sw $t8, 24($t0)
	sw $t8, 28($t0)
	sw $t8, 32($t0)
	sw $t8, 40($t0)
	sw $t8, 56($t0)
	sw $t8, 64($t0)
	sw $t8, 128($t0)
	sw $t8, 136($t0)
	sw $t8, 144($t0)
	sw $t8, 152($t0)
	sw $t8, 160($t0)
	sw $t8, 168($t0)
	sw $t8, 176($t0)
	sw $t8, 184($t0)
	sw $t8, 192($t0)
	sw $t8, 260($t0)
	sw $t8, 268($t0)
	sw $t8, 280($t0)
	sw $t8, 284($t0)
	sw $t8, 288($t0)
	sw $t8, 300($t0)
	sw $t8, 308($t0)
	sw $t8, 448($t0)
	
	lw $t0, displayAddress
	
	li $v0, 32
	la $a0, ($s2)
	syscall
	
	addu $t0, $t0, 1332
	
	sw $t1, 0($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 40($t0)
	sw $t1, 56($t0)
	sw $t1, 64($t0)
	sw $t1, 128($t0)
	sw $t1, 136($t0)
	sw $t1, 144($t0)
	sw $t1, 152($t0)
	sw $t1, 160($t0)
	sw $t1, 168($t0)
	sw $t1, 176($t0)
	sw $t1, 184($t0)
	sw $t1, 192($t0)
	sw $t1, 260($t0)
	sw $t1, 268($t0)
	sw $t1, 280($t0)
	sw $t1, 284($t0)
	sw $t1, 288($t0)
	sw $t1, 300($t0)
	sw $t1, 308($t0)
	sw $t1, 448($t0)
	
	lw $t0, displayAddress
	
	jr $ra
