.data
Message:	.asciiz "Loi chia cho 0"

.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014 
.eqv SEVENSEG_RIGHT 0xFFFF0010 	# dia chi den LED 7 doan phai
.eqv SEVENSEG_LEFT	0xFFFF0011 	# dia chi den LED 7 doan trai

.text
main: 
	li $t1, IN_ADRESS_HEXA_KEYBOARD
 	li $t2, OUT_ADRESS_HEXA_KEYBOARD
	li $t3, 0x08 		# duyet hang c,d,e,f
	li $t4, 0x01 		# duyet hang 0,1,2,3
	li $t5, 0x02 		# duyet hang 4,5,6,7
	li $t6, 0x04 		# duyet hang 8,9,a,b
	
	li $s0, 0x3f 		# Ma hien thi hang don vi
	li $a1, 0x3f 		# Ma hien thi hang chuc
polling: 
	sb $t3, 0($t1) 			# Quet hang c,d,e,f
 	lbu $t0, 0($t2)			# $t0 = ma phim quet duoc. $t0=0 neu ko co phim nao dc an
 	bnez $t0, switch_button 	
 	nop
 	sb $t4, 0($t1 ) 		# Quet hang 0,1,2,3
 	lbu $t0, 0($t2) 
 	bnez $t0, switch_button
 	nop 	
 	sb $t5, 0($t1 ) 		# Quet hang 4,5,6,7
 	lbu $t0, 0($t2) 
 	bnez $t0, switch_button 
 	nop	
 	sb $t6, 0($t1 ) 		# Quet hang 8,9,a,b
 	lbu $t0, 0($t2) 
switch_button: 	
	beq $t0, 0x00, free 		# Ko an phím nào
	beq $t0, 0x11, case_0		# An phím 0
	beq $t0, 0x21, case_1		# An phím 1
	beq $t0, 0x41, case_2		# An phím 2
	beq $t0, 0x81, case_3		# An phím 3
	beq $t0, 0x12, case_4		# An phím 4
	beq $t0, 0x22, case_5		# An phím 5
	beq $t0, 0x42, case_6		# An phím 6
	beq $t0, 0x82, case_7		# An phím 7
	beq $t0, 0x14, case_8		# An phím 8
	beq $t0, 0x24, case_9		# An phím 9
	beq $t0, 0x44, case_a		# An phím a
	beq $t0, 0x84, case_b		# An phím b
	beq $t0, 0x18, case_c		# An phím c
	beq $t0, 0x28, case_d		# An phím d
	beq $t0, 0x88, case_f		# An phím f
	nop
case_0:	
	li $a0, 0x3f		# $a0 = ma hien thi so 0
	li $s2, 0			# $s2 = gia tri phim dc an
	j process_button	
case_1:	
	li $a0, 0x06		# $a0 = ma hien thi so 1
	li $s2, 1
	j process_button
case_2:	
	li $a0, 0x5B		# $a0 = ma hien thi so 2
	li $s2, 2
	j process_button
case_3:	
	li $a0, 0x4f		# $a0 = ma hien thi so 3
	li $s2, 3
	j process_button
case_4:	
	li $a0, 0x66
	li $s2, 4
	j process_button
case_5:	
	li $a0, 0x6D
	li $s2, 5
	j process_button
case_6:	
	li $a0, 0x7d
	li $s2, 6
	j process_button
case_7:	
	li $a0, 0x07
	li $s2, 7
	j process_button
case_8:	
	li $a0, 0x7f
	li $s2, 8
	j process_button
case_9:	
	li $a0, 0x6f
	li $s2, 9
	j process_button
case_a:
	li $t7, '+'		# $t7 = phep tinh cong
	j do_math		# Xu ly phep tinh
case_b:	
	li $t7, '-'		# Phep tru
	j do_math
case_c:
	li $t7, '*'		# Phep nhân
	j do_math
case_d:	
	li $t7, '/'		# Phep chia
	j do_math
case_f:	
	j result		# Neu an dau =
 
free:	
 	move $a0, $s0		# Chuyen Ma phim ve lai $a0
	li $s1, 0			# Dat den bao = 0, phim da duoc tha ra
	j show_number		# Chuyen den phan hien thi
process_button:
 	bnez $s1, show_number	# Kiem tra trang thai cua phim
	move $a1, $s0			# Chuyen ma hien thi sang hang chuc
	bnez $s4, second_number	# Neu la toan hang thu 2 chuyen den xu ly toan hang 2
	mul $s3, $s3, 10		# Xu ly toan hang 1
	add $s3, $s3, $s2		# $s3 luu gia tri so hang thu nhat
	j print_int
second_number:		
	mul $s5, $s5, 10	# Xu ly toan hang 2
	add $s5, $s5, $s2	# $s5 luu gia tri so hang thu 2
		
print_int:	
	move $a0, $s2
	li $v0, 1
	syscall				# In so vua nhan ra console
	j is_old
do_math:	
 	li $a0, 0x3f		# Dat lai ma hien thi so 0
 	li $a1, 0x3f
 	bnez $s1, is_old	# Kiem tra co phim moi duoc bam chua
 	move $a0, $t7
 	li $v0, 11
 	syscall				# Hien thi phep tinh len man hinh console
 	li $s2, 0		# $s2 = 0 (Dat gia tri phim bam hien tai ve 0)
 	li $s4, 1		# $s4 = 1, Xu ly Toan hang thu 2
is_old:	
	li $s1, 1		# $s1 = 1 : Chua co phim moi duoc bam	
	
show_number:	
	move $s0, $a0	# Luu ma hien thi hang don vi
 	jal SHOW_LED_RIGHT 	
 	jal SHOW_LED_LEFT 	
delay: 
 	li $a0, 100 	# sleep 100ms
 	li $v0, 32
	syscall
	nop
back_to_polling: 
	j polling 		
result:
	li $v0, 11
	li $a0, '='
	syscall 	# Hien thi dau =
	
	beq $t7, '+', add	# Thuc hien phep cong
	beq $t7, '-', sub	# Thuc hien phep tru
	beq $t7, '*', mul	# Thuc hien phep nhan
	beq $t7, '/', div	# Thuc hien phep chia
add:	
	add $a0, $s3, $s5
	j show_result
sub:	
	sub $a0, $s3, $s5
	j show_result
mul:	
	mul $a0, $s3, $s5
	j show_result
div:	
	beq $s5, 0 , print_message	# Neu chia cho 0 thi bao loi
	div $a0, $s3, $s5

show_result:
	li $v0, 1
	syscall				# In ket qua ra console
	div $s7, $a0, 10	# $s7 = $a0 / 10 
	mfhi $t0			# so du = hang don vi
	jal DATA_FOR_LED	# gia tri hang don vi --> ma hien thi cua LED
	move $s0, $a0		# $s0 = ma hien thi hang don vi
	div $s7, $s7, 10	# $s7 = $s7 / 10
	mfhi $t0			# so du = hang chuc
	jal DATA_FOR_LED	# gia tri hang chuc --> ma hien thi cua LED
	move $a1, $a0		# $a1 = ma hien thi hang chuc
	
	jal SHOW_LED_RIGHT 	# hien thi LED phai
 	jal SHOW_LED_LEFT  	# hien thi LED trai
 	li $v0, 10		
 	syscall				# Ket thuc chuong trinh

#---------------------------------------------------------------

#---------------------------------------------------------------
SHOW_LED_RIGHT: 
 	sb $s0, SEVENSEG_RIGHT # assign new value
 	jr $ra
SHOW_LED_LEFT:
 	sb $a1, SEVENSEG_LEFT # assign new value
 	jr $ra
DATA_FOR_LED:
	beq $t0, 0, setNumber0
	beq $t0, 1, setNumber1
	beq $t0, 2, setNumber2
	beq $t0, 3, setNumber3
	beq $t0, 4, setNumber4
	beq $t0, 5, setNumber5
	beq $t0, 6, setNumber6
	beq $t0, 7, setNumber7
	beq $t0, 8, setNumber8
	beq $t0, 9, setNumber9
	nop
setNumber0:	
	li $a0, 0x3f
	j END__F
setNumber1:	
	li $a0, 0x06
	j END__F
setNumber2:	
	li $a0, 0x5B
	j END__F
setNumber3:	
	li $a0, 0x4f
	j END__F
setNumber4:	
	li $a0, 0x66
	j END__F
setNumber5:	
	li $a0, 0x6D
	j END__F
setNumber6:	
	li $a0, 0x7d
	j END__F
setNumber7:	
	li $a0, 0x07
	j END__F
setNumber8:	
	li $a0, 0x7f
	j END__F
setNumber9:	
	li $a0, 0x6f
	j END__F
END__F:
	jr $ra	

# Trong truong hop so chia = 0 
print_message:
	li	$v0, 4
	la	$a0, Message
	syscall
	li	$v0, 10
	syscall
