.data
frameBuffer: 	.space 	0x80000		#512 wide x 256 high pixels
xVel:		.word	0		# x velocity start at 0
yVel:		.word	0		# y velocity start at 0
x:		.word	50		# x position (at beginning)
y:		.word	27		# y position (at beginning)
tail:		.word	7624		# tail at beginning
appleX:		.word	32		# apple x position  (at beginning)
appleY:		.word	16		# apple y position  (at beginning)
snakeUp:	.word	0x0000ff00	# green pixel for when  moving up
snakeDown:	.word	0x0100ff00	# green pixel for when  moving down
snakeLeft:	.word	0x0200ff00	# green pixel for when  moving left
snakeRight:	.word	0x0300ff00	# green pixel for when  moving right
xConvert:	.word	64		# x value for converting x to bitmap display
yConvert:	.word	4		# y value for converting (x,y) to bitmap display
temp:		.word   0		# 
message: 	.asciiz  " "
message1:	.asciiz "Game over"

.text
main:

# DRAW BACKGROUND 
	la 	$t0, frameBuffer	# load frame buffer address
	li 	$t1, 8192		# save 512x256 pixels
	li 	$t2, 0x00d3d3d3		# load gray color
draw:
	sw   	$t2, 0($t0)
	addi 	$t0, $t0, 4 		# t0 = t0 + 4
	addi 	$t1, $t1, -1		# decrement number of pixels
	bnez   	$t1, draw		# repeat while number of pixels != 0
	
# DRAW BORDER 
	# top wall 
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t1, $zero, 64		# t1 = 64 length of row
	li 	$t2, 0x00000000		# load black color
drawTopBorder:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 4		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawTopBorder	# repeat unitl pixel count == 0
	
	# bottom wall
	la	$t0, frameBuffer	# load frame buffer addres
	addi	$t0, $t0, 7936		# set pixel to be near the bottom left
	addi	$t1, $zero, 64		# t1 = 512 length of row

drawBotBorder:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 4		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBotBorder	# repeat unitl pixel count == 0
	
	# left wall 
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t1, $zero, 256		# t1 = 512 length of col

drawLeftBorder:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 256		# next pixel
	addi	$t1, $t1, -1		# decrease count
	bnez	$t1, drawLeftBorder	# repeat until pixel count == 0
	
	# right wall 
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t0, $t0, 508		# make starting pixel top right
	addi	$t1, $zero, 255		# t1 = 512 length of col

drawRightBorder:
	sw	$t2, 0($t0)		# color pixel black
	addi	$t0, $t0, 256		# next pixel
	addi	$t1, $t1, -1		# decrease count
	bnez	$t1, drawRightBorder	# repeat until pixel count == 0
	
	# initial snake 
	la	$t0, frameBuffer	# load frame buffer address
	lw	$s2, tail		# s2 = tail of snake
	lw	$s3, snakeUp		# s3 = direction of snake
	
	add	$t1, $s2, $t0		# t1 = tail start on bit map display
	sw	$s3, 0($t1)		# draw pixel where snake is ve mau xanh cho duoi ran
	addi	$t1, $t1, -256		# set t1 to pixel above ( dich len o ben tren)
	sw	$s3, 0($t1)		# draw pixel where snake currently is (ve tiep ran)
	
	# initial apple
	jal 	drawApple

	
moveUp:
	lw	$s3, snakeUp	# s3 = direction of snake
	add	$a0, $s3, $zero	# a0 = direction of snake
	lw	$t1, temp
	mul	$t1,$t1,0
	addi	$t1,$t1,119
	sw	$t1,temp
	jal	updateSnake
	
	# move the snake
	jal 	updateSnakeHeadPosition
	
	j	exitMoving 	

moveDown:
	lw	$s3, snakeDown	# s3 = direction of snake
	add	$a0, $s3, $zero	# a0 = direction of snake
	jal	updateSnake
	
	# move the snake
	jal 	updateSnakeHeadPosition
	
	j	exitMoving
	
moveLeft:
	lw	$s3, snakeLeft	# s3 = direction of snake
	add	$a0, $s3, $zero	# a0 = direction of snake
	jal 	updateSnake
	
	# move the snake
	jal 	updateSnakeHeadPosition
	
	j	exitMoving
	
moveRight:
	lw	$s3, snakeRight	# s3 = direction of snake
	add	$a0, $s3, $zero	# a0 = direction of snake
	jal	updateSnake
	
	# move the snake
	jal 	updateSnakeHeadPosition

	j	exitMoving

	

exitMoving:
	j 	gameUpdateLoop		# loop back to beginning
	
gameUpdateLoop:

	lw	$t3, 0xffff0004	 	# get keypress from keyboard input 
	
	# frame rate = 15
	addi	$v0, $zero, 32	# syscall sleep
	addi	$a0, $zero, 66	# 66 ms
	syscall
	
	
	
	
	beq	$t3, 100, moveRight	# if key press = 'd' branch to moveright
	beq	$t3, 97, moveLeft	# else if key press = 'a' branch to moveLeft
	beq	$t3, 119, moveUp	# if key press = 'w' branch to moveUp
	beq	$t3, 115, moveDown	# else if key press = 's' branch to moveDown
	beq	$t3, 0, moveUp		# start game moving up
	
	
	

updateSnake:
	addiu 	$sp, $sp, -24		# allocate 24 bytes for stack
	sw 	$fp, 0($sp)		# store caller's frame pointer
	sw 	$ra, 4($sp)		# store caller's return address
	addiu 	$fp, $sp, 20		# setup updateSnake frame pointer
	
	# DRAW HEAD
	lw	$t0, x			# t0 = x of snake
	lw	$t1, y			# t1 = y of snake
	lw	$t2, xConvert		# t2 = 64
	mult	$t1, $t2		# y * 64
	mflo 	$t3			# t3 = yPos * 64
	add	$t3, $t3, $t0		# t3 = yPos * 64 + xPos
	lw	$t2, yConvert		# t2 = 4
	mult	$t3, $t2		# (y * 64 + x) * 4
	mflo	$t0			# t0 = (y * 64 + x) * 4
	
	la 	$t1, frameBuffer	# load frame buffer address
	add	$t0, $t1, $t0		# t0 = (y * 64 + x) * 4 + frame address
	lw	$t4, 0($t0)		# save original val of pixel in t4
	sw	$a0, 0($t0)		# store direction plus color on the bitmap display
	
	
	# Set Velocity
	lw	$t2, snakeUp			# load word snake up = 0x0000ff00
	beq	$a0, $t2, setVelocityUp		# if head direction and color == snake up branch to setVelocityUp
	
	lw	$t2, snakeDown			
	beq	$a0, $t2, setVelocityDown	# if head direction and color == snake down branch to setVelocityUp
	
	lw	$t2, snakeLeft			
	beq	$a0, $t2, setVelocityLeft	# if head direction and color == snake left branch to setVelocityUp
	
	lw	$t2, snakeRight			# load word snake up = 0x0300ff00
	beq	$a0, $t2, setVelocityRight	# if head direction and color == snake right branch to setVelocityUp
	
setVelocityUp:
	addi	$t5, $zero, 0		# set x velocity to zero
	addi	$t6, $zero, -1	 	# set y velocity to -1
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j exitVelocitySet
	
setVelocityDown:
	addi	$t5, $zero, 0		# set x velocity to zero
	addi	$t6, $zero, 1 		# set y velocity to 1
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j exitVelocitySet
	
setVelocityLeft:
	addi	$t5, $zero, -1		# set x velocity to -1
	addi	$t6, $zero, 0 		# set y velocity to zero
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j exitVelocitySet
	
setVelocityRight:
	addi	$t5, $zero, 1		# set x velocity to 1
	addi	$t6, $zero, 0 		# set y velocity to zero
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j exitVelocitySet
	
exitVelocitySet:
	
	# Head location checks
	li 	$t2, 0x00ff0000		# load red color
	bne	$t2, $t4, headNotApple	# if head location is not the apple branch to headNotApple
	
	jal 	newAppleLocation
	jal	drawApple
	j	exitUpdateSnake
	
headNotApple:

	li	$t2, 0x00d3d3d3			# load light color
	beq	$t2, $t4, validHeadSquare	# if head location is background branch to validHeadSquare
	
	addi 	$v0,$zero,59
	la	$a0,message
	la	$a1,message1
	syscall
	
	addi 	$v0, $zero, 10			# exit the program
	syscall
	
validHeadSquare:

	# Remove Tail
	lw	$t0, tail			# t0 = tail
	la 	$t1, frameBuffer			# load frame buffer address
	add	$t2, $t0, $t1			# t2 = tail location on the bitmap display
	li 	$t3, 0x00d3d3d3			# load light gray color
	lw	$t4, 0($t2)			# t4 = tail direction and color
	sw	$t3, 0($t2)			# replace tail with background color
	
	# update new Tail
	lw	$t5, snakeUp			# load word snake up = 0x0000ff00
	beq	$t5, $t4, setNextTailUp		# if tail direction and color == snake up branch to setNextTailUp
	
	lw	$t5, snakeDown			# load word snake up = 0x0100ff00
	beq	$t5, $t4, setNextTailDown	# if tail direction and color == snake down branch to setNextTailDown
	
	lw	$t5, snakeLeft			# load word snake up = 0x0200ff00
	beq	$t5, $t4, setNextTailLeft	# if tail direction and color == snake left branch to setNextTailLeft
	
	lw	$t5, snakeRight			# load word snake up = 0x0300ff00
	beq	$t5, $t4, setNextTailRight	# if tail direction and color == snake right branch to setNextTailRight
	
setNextTailUp:
	addi	$t0, $t0, -256		# tail = tail - 256
	sw	$t0, tail		# store new tail
	j exitUpdateSnake
	
setNextTailDown:
	addi	$t0, $t0, 256		# tail = tail + 256
	sw	$t0, tail		# store new tail
	j exitUpdateSnake
	
setNextTailLeft:
	addi	$t0, $t0, -4		# tail = tail - 4
	sw	$t0, tail		# store new tail
	j exitUpdateSnake
	
setNextTailRight:
	addi	$t0, $t0, 4		# tail = tail + 4
	sw	$t0, tail		# store new tail
	j exitUpdateSnake
	
exitUpdateSnake:
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code
	
updateSnakeHeadPosition:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer	
	
	lw	$t3, xVel	# load xVel from memory
	lw	$t4, yVel	# load yVel from memory
	lw	$t5, x		# load xPos from memory
	lw	$t6, y		# load yPos from memory
	add	$t5, $t5, $t3	# update x pos
	add	$t6, $t6, $t4	# update y pos
	sw	$t5, x		# store updated x back to memory
	sw	$t6, y		# store updated y back to memory
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code


drawApple:
	addiu 	$sp, $sp, -24		# allocate 24 bytes for stack
	sw 	$fp, 0($sp)		# store caller's frame pointer
	sw 	$ra, 4($sp)		# store caller's return address
	addiu 	$fp, $sp, 20		# setup updateSnake frame pointer
	
	lw	$t0, appleX		# t0 = xPos of apple
	lw	$t1, appleY		# t1 = yPos of apple
	lw	$t2, xConvert		# t2 = 64
	mult	$t1, $t2		# appleY * 64
	mflo	$t3			# t3 = appleY * 64
	add	$t3, $t3, $t0		# t3 = appleY * 64 + appleX
	lw	$t2, yConvert		# t2 = 4
	mult	$t3, $t2		# (y * 64 + appleX) * 4
	mflo	$t0			# t0 = (appleY * 64 + appleX) * 4
	
	la 	$t1, frameBuffer		# load frame buffer address
	add	$t0, $t1, $t0		# t0 = (appleY * 64 + appleX) * 4 + frame address
	li	$t4, 0x00ff0000
	sw	$t4, 0($t0)		# store direction plus color on the bitmap display
	
	lw 	$ra, 4($sp)		# load caller's return address
	lw 	$fp, 0($sp)		# restores caller's frame pointer
	addiu 	$sp, $sp, 24		# restores caller's stack pointer
	jr 	$ra			# return to caller's code	


newAppleLocation:
	addiu 	$sp, $sp, -24		# allocate 24 bytes for stack
	sw 	$fp, 0($sp)		# store caller's frame pointer
	sw 	$ra, 4($sp)		# store caller's return address
	addiu 	$fp, $sp, 20		# setup updateSnake frame pointer

random:		
	addi	$v0, $zero, 42		# random int 
	addi	$a1, $zero, 63		# upper bound
	syscall
	add	$t1, $zero, $a0		# random appleX
	
	addi	$v0, $zero, 42		# random int 
	addi	$a1, $zero, 31		# upper bound
	syscall
	add	$t2, $zero, $a0		# random appleY
	
	lw	$t3, xConvert		# t3 = 64
	mult	$t2, $t3		# random appleY * 64
	mflo	$t4			# t4 = random appleY * 64
	add	$t4, $t4, $t1		# t4 = random appleY * 64 + random appleX
	lw	$t3, yConvert		# t3 = 4
	mult	$t3, $t4		# (random appleY * 64 + random appleX) * 4
	mflo	$t4			# t1 = (random appleY * 64 + random appleX) * 4
	
	la 	$t0, frameBuffer	# load frame buffer address
	add	$t0, $t4, $t0		# t0 = (appleY * 64 + appleX) * 4 + frame address
	lw	$t5, 0($t0)		# t5 = value of pixel at t0
	
	li	$t6, 0x00d3d3d3		# load gray color
	beq	$t5, $t6, goodApple	# if location is a good square branch to goodApple
	j random

goodApple:
	sw	$t1, appleX
	sw	$t2, appleY	

	lw 	$ra, 4($sp)		# load caller's return address
	lw 	$fp, 0($sp)		# restores caller's frame pointer
	addiu 	$sp, $sp, 24		# restores caller's stack pointer
	jr 	$ra			# return to caller's code

