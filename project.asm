.data 
	frameBuffer: 	.space 	0x100000	# 512 wide x 512 high pixels
	xVel:		.word	0		# x velocity start 0
	yVel:		.word	0		# y velocity start 0
	xPos:		.word	256		# x position
	yPos:		.word	256		# y position
	tail:		.word	0		# location of rail on bit map display
	circleUp:	.word	0x0000ff00	# green pixel for when snaking moving up
	circleDown:	.word	0x0100ff00	# green pixel for when snaking moving down
	circleLeft:	.word	0x0200ff00	# green pixel for when snaking moving left
	circleRight:	.word	0x0300ff00	# green pixel for when snaking moving right
	xConversion:	.word	512		# x value for converting xPos to bitmap display
	yConversion:	.word	4		# y value for converting (x, y) to bitmap display
.text
main:
	# draw border
	la 	$t0, frameBuffer	# load frame buffer addres
	li 	$t1, 512		# save 512*512 pixels
	li 	$t2, 0xFF4500		# load light gray color
drawBorderTop:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 4		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderTop	# repeat unitl pixel count == 0
# Bottom wall section
	la	$t0, frameBuffer	# load frame buffer addres
	addi	$t0, $t0, 1046528		# set pixel to be near the bottom left
	addi	$t1, $zero, 512		# t1 = 512 length of row

drawBorderBot:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 4		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderBot	# repeat unitl pixel count == 0
# left wall section
	la	$t0, frameBuffer
	addi	$t1, $zero, 511		# t1 = 512 length of col

drawBorderLeft:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 2048		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderLeft	# repeat unitl pixel count == 0
	
	# Right wall section
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t0, $t0, 2044		# make starting pixel top right
	addi	$t1, $zero, 511		# t1 = 512 length of col

drawBorderRight:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 2048		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderRight	# repeat unitl pixel count == 0
# if input == w { moveUp();}
# if input == s { moveDown();}	
# if input == a { moveLeft();}	
# if input == d { moveRigth();}	

# if input == w { moveUp();}
# if input == s { moveDown();}	
# if input == a { moveLeft();}	
# if input == d { moveRigth();}	

gameUpdateLoop:

	lw	$t3, 0xffff0004		# get keypress from keyboard input
	
	### Sleep for 66 ms so frame rate is about 15
	addi	$v0, $zero, 32	# syscall sleep
	addi	$a0, $zero, 66	# 66 ms
	syscall
	
	beq	$t3, 100, moveRight	# if key press = 'd' branch to moveright
	beq	$t3, 97, moveLeft	# else if key press = 'a' branch to moveLeft
	beq	$t3, 119, moveUp	# if key press = 'w' branch to moveUp
	beq	$t3, 115, moveDown	# else if key press = 's' branch to moveDown
	beq	$t3, 0, moveUp		# start game moving up
moveUp:
	lw	$s3, circleUp	# s3 = direction of circle
	add	$a0, $s3, $zero	# a0 = direction of circle
	jal	updatecircle
	
	# move the circle
	jal 	updateCirclePosition
	
	j	exitMoving 	

moveDown:
	lw	$s3, circleDown	# s3 = direction of circle
	add	$a0, $s3, $zero	# a0 = direction of circle
	jal	updatecircle
	
	# move the circle
	jal 	updateCirclePosition
	
	j	exitMoving
	
moveLeft:
	lw	$s3, circleLeft	# s3 = direction of circle
	add	$a0, $s3, $zero	# a0 = direction of circle
	jal	updatecircle
	
	# move the circle
	jal 	updateCirclePosition
	
	j	exitMoving
	
moveRight:
	lw	$s3, circleRight	# s3 = direction of circle
	add	$a0, $s3, $zero	# a0 = direction of circle
	jal	updatecircle
	
	# move the circle
	jal 	updateCirclePosition

	j	exitMoving

exitMoving:
	j 	gameUpdateLoop		# loop back to beginning

#	updatecircle: get position center circle -> Velocity -> check -? print
#	getNextPosUp: *********************************************************
#	getNextPosDown	*********************************************************
#	getNextPosLeft	*********************************************************
#	getNextPosRight	*********************************************************
#
updatecircle:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updatecircle frame pointer
	
	### DRAW HEAD
	lw	$t0, xPos		# t0 = xPos of circle
	lw	$t1, yPos		# t1 = yPos of circle
	lw	$t2, xConversion	# t2 = 512
	mult	$t1, $t2		# yPos * 512
	mflo	$t3			# t3 = yPos * 64
	add	$t3, $t3, $t0		# t3 = yPos * 64 + xPos
	lw	$t2, yConversion	# t2 = 4
	mult	$t3, $t2		# (yPos * 64 + xPos) * 4
	mflo	$t0			# t0 = (yPos * 64 + xPos) * 4
	la	$a1, tail
	sw	$t0,0($a1)
	
	la 	$t1, frameBuffer	# load frame buffer address
	add	$t0, $t1, $t0		# t0 = (yPos * 64 + xPos) * 4 + frame address
	li 	$t5, 31
	li 	$t6, 0x00FFFF00		# t6 - yellow
	beq	$a0, 0x0000ff00, getNextPosUp	# xem huong di de doi chieu neu la canh tren
	beq	$a0, 0x0100ff00, getNextPosDown
	beq	$a0, 0x0200ff00, getNextPosLeft
	beq	$a0, 0x0300ff00, getNextPosRight
	
getNextPosUp:
	addi $t7, $t0, -32768	# o 16 phia tren
	lw   $t8 ,0($t7)	# lay mau
	beq  $t8, 0xFF4500, swapVelocityUp	# dung mau thi doi huong
	j	loop			# in ra binh thuong
getNextPosDown:	
	addi $t7, $t0, 30720	# o 16 phia duoi
	lw   $t8 ,0($t7)	# lay mau
	beq  $t8, 0xFF4500, swapVelocityDown	# dung mau thi doi huong
	j	loop		# in ra binh thuong
getNextPosLeft:	
	addi $t7, $t0, -64
	lw   $t8 ,0($t7)
	beq  $t8, 0xFF4500, swapVelocityLeft
	j	loop
getNextPosRight:
	addi $t7, $t0, 64	
	lw   $t8 ,0($t7)
	beq  $t8, 0xFF4500, swapVelocityRight
	j	loop
	#star print circle
loop:
	lw	$t0, xPos		# t0 = xPos of circle
	lw	$t1, yPos		# t1 = yPos of circle
	addi	$t2,$t0,-15		# ban kinh bang 15
	addi	$t3,$t1,-15
	addi	$t4,$t1,15		
	li	$t5,31			# t5 = 15+15+1 
circle:
	sub	$t7,$t2,$t0		# t7 = toa do diem tru toa do tam theo x
	mul 	$t7,$t7,$t7		#	binh phuong
	sub	$t8,$t3,$t1		#	giong t7	nhung la theo y
	mul	$t8,$t8,$t8
	add	$t9,$t7,$t8		# x^2 + y^2
	addi	$t9,$t9,-225		# - R^2
	bltzal	$t9,circle15		# so sanh vo 0 neu nho hon thi chuyen den buoc tiep theo
	addi	$t2,$t2,1		# tang x va lap lai
	addi 	$t5, $t5, -1
	beqz	$t5, reset
	bnez	$t5,  circle
	
reset:	# tang y len 1 dua x ve gia tri ban dau
	li	$t5,31
	addi	$t2,$t2,-31
	addi	$t3,$t3,1
	beq	$t3,$t4,sleep
	j	circle
circle15:	# neu da nam trong vong tron 15 thi can theo dieu kien nam ngoai duong tron ban kinh 14
	addi	$t9,$t9,29	# 29 = 15^2-14^2
	bgezal	$t9,print	# thoa man thi in ra khong thi quay lai lap
	addi	$t2,$t2,1
	addi 	$t5, $t5, -1
	j	circle
print:
	lw	$t7, xConversion	# t7 = 512
	mult	$t3, $t7		# yPos * 512
	mflo	$s3			# s3 = yPos * 64
	add	$s3, $s3, $t2		# s3 = yPos * 64 + xPos
	lw	$s4, yConversion	# s4 = 4
	mult	$s3, $s4		# (yPos * 64 + xPos) * 4
	mflo	$s5			# s5 = (yPos * 64 + xPos) * 4
	la 	$s6, frameBuffer	# load frame buffer address
	add	$s5, $s5, $s6		# s5 = (yPos * 64 + xPos) * 4 + frame address
	sw	$t6,0($s5)		
	addi	$t2,$t2,1
	addi 	$t5, $t5, -1
	j	circle
	
sleep:
	move 	$a1 , $a0
	addi	$v0, $zero, 32	# syscall sleep
	addi	$a0, $zero, 10	# 400 ms
	syscall
	
	#end print circle
	
	move 	$a0 , $a1
	### Set Velocity
	lw	$t2, circleUp			# load word circle up = 0x0000ff00
	beq	$a0, $t2, setVelocityUp		# if head direction and color == circle up branch to setVelocityUp
	
	lw	$t2, circleDown			# load word circle up = 0x0100ff00
	beq	$a0, $t2, setVelocityDown	# if head direction and color == circle down branch to setVelocityUp
	
	lw	$t2, circleLeft			# load word circle up = 0x0200ff00
	beq	$a0, $t2, setVelocityLeft	# if head direction and color == circle left branch to setVelocityUp
	
	lw	$t2, circleRight		# load word circle up = 0x0300ff00
	beq	$a0, $t2, setVelocityRight	# if head direction and color == circle right branch to setVelocityUp			
setVelocityUp:
	addi	$t5, $zero, 0		# set x velocity to zero
	addi	$t6, $zero, -10	 	# set y velocity to -1
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j removeCirle			# xoa di de them moi
	
setVelocityDown:
	addi	$t5, $zero, 0		# set x velocity to zero
	addi	$t6, $zero, 10 		# set y velocity to 1
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j removeCirle
	
setVelocityLeft:
	addi	$t5, $zero, -10		# set x velocity to -1
	addi	$t6, $zero, 0 		# set y velocity to zero
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j removeCirle
	
setVelocityRight:
	addi	$t5, $zero, 10		# set x velocity to 1
	addi	$t6, $zero, 0 		# set y velocity to zero
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j removeCirle

swapVelocityUp:	# neu gap canh thi doi chieu
	li	$t3, 0xffff0004		# dia chi cua keyboard
	li	$t4, 115		# s
	sw	$t4,0($t3)		# luu lai
	j	 moveDown	# if head direction and color == circle down branch to setVelocityUp
swapVelocityDown:	# tuong tu
	li	$t3, 0xffff0004
	li	$t4, 119
	sw	$t4,0($t3)
	j	 moveUp			# if head direction and color == circle down branch to setVelocityUp
swapVelocityLeft:
	li	$t3, 0xffff0004
	li	$t4, 100
	sw	$t4,0($t3)
	j	 moveRight		# if head direction and color == circle down branch to setVelocityUp
swapVelocityRight:
	li	$t3, 0xffff0004
	li	$t4, 97
	sw	$t4,0($t3)
	j	 moveLeft		# if head direction and color == circle down branch to setVelocityUp

removeCirle:   #xoa di de them moi	# xoa giong in chi khac la thay bang mau blaclk
	li 	$t5, 31
	li 	$t6, 0x00000000		# t6 - black
	lw	$t0, xPos		# t0 = xPos of circle
	lw	$t1, yPos		# t1 = yPos of circle
	addi	$t2,$t0,-15
	addi	$t3,$t1,-15
	addi	$t4,$t1,15
circle_r:
	sub	$t7,$t2,$t0
	mul 	$t7,$t7,$t7
	sub	$t8,$t3,$t1
	mul	$t8,$t8,$t8
	add	$t9,$t7,$t8
	addi	$t9,$t9,-225
	bltzal	$t9,circle15_r
	addi	$t2,$t2,1
	addi 	$t5, $t5, -1
	beqz	$t5, reset_r
	bnez	$t5,  circle_r
	
reset_r:
	li	$t5,31
	addi	$t2,$t2,-31
	addi	$t3,$t3,1
	beq	$t3,$t4,sleep_r
	j	circle_r
circle15_r:
	addi	$t9,$t9, 29	# 15 binh phuong tru 14 binh phuong
	bgezal	$t9,print_r
	addi	$t2,$t2,1
	addi 	$t5, $t5, -1
	j	circle_r
print_r:
	lw	$t7, xConversion	# t2 = 512
	mult	$t3, $t7		# yPos * 512
	mflo	$s3			# t3 = yPos * 64
	add	$s3, $s3, $t2		# t3 = yPos * 64 + xPos
	lw	$s4, yConversion	# t2 = 4
	mult	$s3, $s4		# (yPos * 64 + xPos) * 4
	mflo	$s5			# t0 = (yPos * 64 + xPos) * 4
	la 	$s6, frameBuffer	# load frame buffer address
	add	$s5, $s5, $s6		# t0 = (yPos * 64 + xPos) * 4 + frame address
	sw	$t6,0($s5)
	addi	$t2,$t2,1
	addi 	$t5, $t5, -1
	j	circle_r
	
sleep_r:	
	move 	$a1 , $a0
	addi	$v0, $zero, 32	# syscall sleep
	addi	$a0, $zero, 1	# 1000 ms
	syscall
	
	move 	$a0 , $a1
	### update new Tail
	lw	$t5, circleUp			# load word circle up = 0x0000ff00
	beq	$t5, $a0, setNextTailUp		# if tail direction and color == circle up branch to setNextTailUp
	
	lw	$t5, circleDown			# load word circle up = 0x0100ff00
	beq	$t5, $a0, setNextTailDown	# if tail direction and color == circle down branch to setNextTailDown
	
	lw	$t5, circleLeft			# load word circle up = 0x0200ff00
	beq	$t5, $a0, setNextTailLeft	# if tail direction and color == circle left branch to setNextTailLeft
	
	lw	$t5, circleRight			# load word circle up = 0x0300ff00
	beq	$t5, $a0, setNextTailRight	# if tail direction and color == circle right branch to setNextTailRight
	
setNextTailUp:
	la	$t0,tail
	addi	$t0, $t0, -2048		# tail = tail - 2048
	sw	$t0, tail		# store  tail in memory
	j exitUpdatecircle
	
setNextTailDown:
	la	$t0,tail
	addi	$t0, $t0, 2048		# tail = tail + 2048
	sw	$t0, tail		# store  tail in memory
	j exitUpdatecircle
	
setNextTailLeft:
	la	$t0,tail
	addi	$t0, $t0, -4		# tail = tail - 4
	sw	$t0, tail		# store  tail in memory
	j exitUpdatecircle
	
setNextTailRight:
	la	$t0,tail
	addi	$t0, $t0, 4		# tail = tail + 4
	sw	$t0, tail		# store  tail in memory
	j exitUpdatecircle
	
exitUpdatecircle:
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code
updateCirclePosition:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updatecircle frame pointer	
	
	lw	$t3, xVel	# load xVel from memory
	lw	$t4, yVel	# load yVel from memory
	lw	$t5, xPos	# load xPos from memory
	lw	$t6, yPos	# load yPos from memory
	add	$t5, $t5, $t3	# update x pos
	add	$t6, $t6, $t4	# update y pos
	sw	$t5, xPos	# store updated xpos back to memory
	sw	$t6, yPos	# store updated ypos back to memory
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code
exit:
