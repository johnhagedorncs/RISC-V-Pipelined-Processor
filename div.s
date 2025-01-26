	.data
student:
	.asciz "Student" 	
	.globl	student
nl:	.asciz "\n"
	.globl nl


op1:	.word 0				# divisor for testing
op2:	.word 19			# dividend for testing


	.text

	.globl main
main:					# main has to be a global label
	addi	sp, sp, -4		# Move the stack pointer
	sw 	ra, 0(sp)		# save the return address

	mv	t0, a0			# Store argc
	mv	t1, a1			# Store argv
				
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
	jal	divide			# go to divide code

	jal	print_result		# print operands to the console

					# Usual stuff at the end of the main
	lw	ra, 0(sp)		# restore the return address
	addi	sp, sp, 4

	li      a7, 10
	ecall


divide:
##############################################################################
# Your code goes here.
# Should have the same functionality as running
#	divu	a2, a1, a0
# 	remu    a3, a1, a0 
# assuming a1 is unsigned divident, and a0 is unsigned divisor
##############################################################################
    li     a2, 0 #Initialize quotient -> 0; C: a2 = 0
    li     a3, 0 #Initialize remainder (R) -> 0; C: a3 = 0
    
    li     t3, 31 #Loop counter = 31 (32-bit division); C: t3 = 31
    #Check if divisor (a0) = 0
    bne    a0, zero, division_loop #If divisor != 0, division_loop; C: if(a0 == 0){a2 = 0, a3 = 0, break}

    #If divisor = 0, set quotient and remainder = 0
    jr      ra #Skip division loop / end; C: break

division_loop:
    slli   a3, a3, 1 #Left shift remainder 1; C: ( a3 = a3 << 1)
    srl    t1, a1, t3 #Get i-th bit of dividend A; C: t1 = a1 >> t3
    andi   t1, t1, 1 #Isolate least significant bit; C: t1 = t1 & 1
    or     a3, a3, t1 #Set less significant bit (R) to Ai; C: a3 = a3 | t1.
	
	#Subtract divisor B from remainder R to get D
    sub    t4, a3, a0 #C: t4 = a3 - a0
    bge    t4, zero, set_quotient_bit #If D > or = 0, set quotient bit = 1; C: if(t4 < 0){skip_set_quotient_bit}
    j      skip_set_quotient_bit #else statement = set quotient bit = 0

set_quotient_bit:
    mv     a3, t4 #Remainder R = D; C: a3 = t4
    slli   a2, a2, 1 #Shift quotient left 1 bit; C: a2 = a2<<1
    addi   a2, a2, 1 #Least signif bit of quotient sets = 1; C: a2 += 1
    j      shift_to_next_bit #Skip skip_set_quotient_bit

skip_set_quotient_bit:
    slli   a2, a2, 1 #Shift quotient left 1 bit, set LSB = 0; C: a2 = a2<<1

shift_to_next_bit:
    addi   t3, t3, -1 #Decrement loop; C: t3-=1
    bgez   t3, division_loop #Cont loop so all bits processed; C: while(t3>0){division_loop}
##############################################################################
# Do not edit below this line
##############################################################################
	jr	ra


# Prints a0, a1, a2, a3
print_result:
	mv	t0, a0
	li	a7, 4
	la	a0, nl
	ecall

	mv	a0, t0
	li	a7, 1
	ecall
	li	a7, 4
	la	a0, nl
	ecall

	li	a7, 1
	mv	a0, a1
	ecall
	li	a7, 4
	la	a0, nl
	ecall

	li	a7, 1
	mv	a0, a2
	ecall
	li	a7, 4
	la	a0, nl
	ecall

	li	a7, 1
	mv	a0, a3
	ecall
	li	a7, 4
	la	a0, nl
	ecall

	jr ra
