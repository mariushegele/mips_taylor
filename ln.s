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
    jal read_float
    mov.s $f12, $f0  # set read float as arg

    # Execute Function
    jal ln0

    # Store Result
    s.s $f0, z

    # Print Function Result
    mov.s $f12, $f0    # move $f0 to $f12
    jal print_float

    # Prompt if Done
    jal prompt_redo


#########       ln0         #########

# config:       $f3 = K
# arg:          $f12 = x
# internal:     $f1 = el, $f2 = i
# return:       $f0 = sum

ln0:
    li.s $f3, 10000.0             # K = 1000

    li.s $f5, 1.0               # f5 = 1.0
    sub.s $f1, $f12, $f5        # el = x - 1.0
    
    li.s $f6, 0.0             # $f6 = 0
    add.s $f0, $f1, $f6         # sum = el

    li.s $f2, 2.0               # float i = 2

loop: 
    
    sub.s $f7, $f2, $f5         # f7 = i - 1
    mul.s $f1, $f1, $f7         # el = el * (i-1)

    sub.s $f8, $f5, $f12        # f8 = 1 - x
    div.s $f8, $f8, $f2         # f8 = (1 - x) / i
    mul.s $f1, $f1, $f8         # el = el * (1-x) / i

    add.s $f0, $f0, $f1         # sum += el

    add.s $f2, $f2, $f5         # i++

    c.lt.s $f2, $f3             # c = (i < K)
    bc1t loop                   # if c return

    jr $ra                      # else return


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