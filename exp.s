# Start with data declarations
#
.data 
x_prompt: .asciiz "Enter x: "
res: .asciiz "\nexp(x) = "
done_prompt: .asciiz " Done [0 = Yes, 1 = No]: "
newline: .asciiz "\n"

zero: .float 0.0

.align 2

z: .word 4
btemp: .word 4
exptemp: .word 4

.globl main
.text			

main:
    # Print Prompt
    la $a0, x_prompt
    jal prompt

    # Read x
    jal read_float
    mov.s $f12, $f0  # set read float as arg

    li $a1, 6 # set number of terms to constant of 6

    # Execute Function
    jal exp

    # Print Function Result
    mov.s $f12, $f0    # move $f0 to $f12
    jal print_float

    # Prompt if Done
    jal prompt_redo


#########      exp       #########

# arg:          $f12 = x //TODO: $a1 = n
# internal:     $f1 = a, $f2 = result of power
# return:       $f0 = 

exp:
    li.s $f1, 0.0           # result = 0.0
    li $t0, 0               # i = 0
    move $t3, $ra  # stash stack pointer

exp_loop:

    bge $t0, $a1, exp_ret # if i>=n jump out of loop

    move $a2, $t0 # exponent of power in a2
    jal power

    lwc1 $f3, zero
    add.s $f2, $f0, $f3 # result of power in f2
    
    move $a2, $t0 # parameter of fact = 1
    jal fact

    mtc1 $v0, $f0
    cvt.s.w $f0, $f0
    div.s $f2, $f2, $f0 # power/fact

    add.s $f1, $f1, $f2 # result += power/fact
    addi $t0, $t0, 1
    j exp_loop

exp_ret:
    add.s $f0, $f1, $f3
    jr $t3


#########       power         #########

# args:         $a2 = exponent, $f12 = x
# return:       $f0 = power x^exponent

power:
    li.s $f2, 1.0

power_loop:
    li $t1, 0
    ble $a2, $t1, power_ret  # branch if exponent <= 0
    mul.s $f2, $f2, $f12
    addi $a2, $a2, -1

    j power_loop

power_ret:
    add.s $f0, $f2, $f3 # copy f2 to f0
    jr $ra


#########       fact         #########

# args:         $a2 = x
# return:       $v0 = fact(i)

fact:
    li $t2, 1 # i
    li $v0, 1 # result

fact_loop:

    bgt $t2, $a2, fact_ret  # branch if i > parameter

    mul $v0, $v0, $t2
    addi $t2, $t2, 1

    j fact_loop

fact_ret:
    jr $ra


######### Helper I/O functions  #########
prompt:
    li		$v0, 4		# system call #4 - print string
    syscall				# execute
    jr $ra

read_float:
    li      $v0, 6
    syscall
    jr $ra

read_int:
    li      $v0, 5
    syscall
    jr $ra

print_float:
    li      $v0, 4
    la      $a0, res
    syscall

    li      $v0, 2 # print float in $f12
    syscall

	la $a0, newline	# print the new line character to force a carriage return 
	li $v0, 4		# on the console
	syscall

    jr $ra

print_int:
    move $a1, $a0   # stash argument

    li      $v0, 4
    la      $a0, res
    syscall

    move $a0, $a1   # restore argument
    li      $v0, 1
    syscall

	la $a0, newline	# print the new line character to force a carriage return 
	li $v0, 4		# on the console
	syscall

    jr $ra

prompt_redo:
    la $a0, done_prompt	# Load address of string 5 into register $a0
	li $v0, 4		# Load I/O code to print string to console
	syscall			# print string

	li $v0, 5		# an I/O sequence to read an integer from the console
	syscall

	bne $v0, $0, main	# if not complete (i.e., you provided 0) then start at the beginning

    li $v0, 10		# syscall code 10 for terminating the program
	syscall

