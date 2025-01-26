	.data
student:
	.asciz "Student" 	
	.globl	student
nl:	.asciz "\n"
	.globl nl


op1:	.word 10			# change the multiplication operands
op2:	.word 11			# for testing.


	.text

	.globl main
main:					# main has to be a global label
	addi	sp, sp, -4		# Move the stack pointer
	sw 	ra, 0(sp)		# save the return address

	mv	t0, a0			# Store argc
	mv	t1, a1			# Store argv

# a7 = 8 read character
#  ecall
				
	li	a7, 4			# print_str (system call 4)
	la	a0, student		# takes the address of string as an argument 
	ecall	

	slti	t2, t0, 2		# check number of arguments
	bne     t2, zero, operands
	j	ready

operands:
	la	t0, op1
	lw	a0, 0(t0)
	la	t0, op2
	lw	a1, 0(t0)
		

ready:
	jal	multiply		# go to multiply code

	jal	print_result		# print operands to the console




					# Usual stuff at the end of the main
	lw	ra, 0(sp)		# restore the return address
	addi	sp, sp, 4
	
	li      a7, 10
	ecall


multiply:
##############################################################################
# Your code goes here.
# Should have the same functionality as running 
#	mul	a2, a1, a0
# assuming a1 and a0 stores 8 bit unsigned numbers
##############################################################################
    
	mv     t2, a0 #C: t2 = a0
    mv     t3, a1 #C: t3 = a1
    li     a2, 0  #C: a2 = 0
    li     t5, 31 #C:Loop counter - 32 bit multiplication
multiply_loop:
    andi   t4, t3, 1 #Check if the LSB of the multiplier is = 1; C: t4 = t3 & 1
    beq    t4, zero, skip_add #If LSB = 0, skip add; #C: if(t4 != 0){a2 += t2} 
    add    a2, a2, t2 #Add multiplicand to result if LSB = 1; C: a2 += t2
skip_add: 
    slli    t2, t2, 1 #Shift multiplicand left 1 bit; C: t2 = t2<<1
    srli    t3, t3, 1 #Shift multiplier right 1 bit; C: t3 = t3>>1
    addi   t5, t5, -1 #Decrement loop; t5 = t5 - 1
    bne   t5, zero, multiply_loop #C: while(t5>0){multiply loop, t5 = t5 - 1}

##############################################################################
# Do not edit below this line
##############################################################################
	jr	ra


print_result:

# print string or integer located in a0 (code a7 = 4 for string, code a7 = 1 for integer) 
	mv	t0, a0
	li	a7, 4
	la	a0, nl
	ecall
	
# print integer
	mv	a0, t0
	li	a7, 1
	ecall
# print string
	li	a7, 4
	la	a0, nl
	ecall
	
# print integer
	li	a7, 1
	mv	a0, a1
	ecall
# print string	
	li	a7, 4
	la	a0, nl
	ecall
	
# print integer
	li	a7, 1
	mv	a0, a2
	ecall
# print string	
	li	a7, 4
	la	a0, nl
	ecall

	jr      ra
