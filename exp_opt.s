# Start with data declarations
#
.data 
x_prompt: .asciiz "Enter x: "
res: .asciiz "\nexp(x) = "
done_prompt: .asciiz " Done [0 = Yes, 1 = No]: "
newline: .asciiz "\n"
space: .asciiz " "

.align 2

z: .word 4
btemp: .word 4
exptemp: .word 4

.globl main
.text			

main:    
    # Print X-Prompt
    la      $a0, x_prompt
    jal     print

    # Read X from user
    jal     read_float
    mov.s   $f12, $f0  # set read float as arg

    # determine optimal number of iterations for x = f12
    jal opt_terms 
    mov.s $f13, $f0

    # Execute Function
    jal exp

    # Store Result
    s.s $f0, z

    # Print Function Result
    mov.s $f12, $f0    # move $f0 to $f12
    jal print_result

    # Prompt if Done
    jal prompt_redo

#########      opt_terms       #########

# arg:          $f12 = x
# internal:     
# return:       $f0 = n = optimal number of terms for x according to approximation

opt_terms:
    li.s $f0, 34.0   # possible iterations
    li.s $f2, 14.0    # $f2 = 14
    c.lt.s $f12, $f2  # parameter < 14
    bc1t return_opt  # return if (parameter less than 14)

    li.s $f3, 10.0    # $f3 = 10
    add.s $f0, $f12, $f3   # $f0 = parameter + 10

    li.s $f3, 430.0   # $f3 = 430
    div.s $f0, $f3, $f0   # $f0 = 430 / $f0

    add.s $f0, $f0, $f2

return_opt:
    jr $ra

#########      exp       #########

# arg:          $f12 = x, $f13 = n
# internal:     $f0 = result, $f2 = numerator, $f3 = denominator, $f4 = i, $f5 = 'part'(numerator/denominator)
#               $f6 = saveplace for $f12 (for prints), $f7 = zero, $f8 = 1.0
# return:       $f0 = result

exp:
    li.s $f0, 0.0           # result = 1.0
    li.s $f2, 1.0           # numerator = 1.0
    li.s $f3, 1.0           # denominator = 1.0
    li.s $f4, 1.0           # i = 1
    li.s $f8, 1.0           # f8 = 1.0
    move $t3, $ra           # stash stack pointer

exp_loop:
    c.le.s $f13, $f4        # i <= n
    bc1t exp_ret            # until i > n

    mul.s $f2, $f2, $f12    # numerator = numerator * x
    mul.s $f3, $f3, $f4     # denominator = denominator * i

    div.s $f5, $f2, $f3     # part = numerator/denominator

    add.s $f0, $f0, $f5     # result += numerator / denominator
    
    add.s $f4, $f4, $f8    # i++
    j exp_loop

exp_ret:

    jr $t3 # result is in $f0


######### Helper I/O functions  #########
print:
    li		$v0, 4		# system call 4 (= print string)
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

# print_result manipulates contents of: $v0, $a0
print_result:
    li      $v0, 4
    la      $a0, res
    syscall

    li      $v0, 2  # print float in $f12
    syscall

	la $a0, newline	# print the new line character to force a carriage return 
	li $v0, 4		# on the console
	syscall

    jr $ra

# print_float manipulates contents of: $v0, $a0
print_float:
    li      $v0, 4
    la      $a0, space
    syscall

    li      $v0, 2  # print float in $f12
    syscall

    li      $v0, 4
    la      $a0, space
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

