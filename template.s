# Template for MIPS programs with I/O

# Start with data declarations
#
.data 
n_prompt: .asciiz "Enter N: "
res: .asciiz "Result = "
done_prompt: .asciiz " Done [0 = Yes, 1 = No]: "
newline: .asciiz "\n"

.align 2

z:  .word 4

.globl main			# leave this here for the moment
.text			

main:
    # Print Prompt
    la		$a0, n_prompt
    jal prompt

    # Read N
    jal read
    move $a0, $v0

    # Execute Function
    jal fun
    move $s0, $v0

    # Store Result
    sw $s0, z

    # Print Function Result
    or  $a0, $zero, $s0
    jal print

    # Prompt if Done
    jal prompt_redo


#########       Function         #########
fun:
    li $v0, 1
loop:
    beq $a0, 0, ret
    mult $a0, $v0
    mflo $v0
    addi $a0, -1
    j loop
ret:
    jr $ra


######### Helper I/O functions  #########
prompt:
    li		$v0, 4		# system call #4 - print string
    syscall				# execute
    jr $ra

read:
    li      $v0, 5
    syscall
    jr $ra

print:
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