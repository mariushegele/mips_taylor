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
    jal ln

    # Store Result
    s.s $f0, z

    # Print Function Result
    mov.s $f12, $f0    # move $f0 to $f12
    jal print_float

    # Prompt if Done
    jal prompt_redo


#########       ln        #########

# arg:          $f12 = x
# internal:     $f1 = a, $f2 / $f9 = b
# return:       $f0 = ln0(0) + b * ln0(2)

ln:
    li.s $f2, 0.0           # b = 0
    mov.s $f1, $f12         # a = x

    li.s $f3, 1.0
    li.s $f4, 2.0
    
loop_ln: 
    c.le.s $f1, $f4         # (a <= 2)? return : loop
    bc1t ret_ln

    div.s $f1, $f1, $f4        # a = a / 2
    
    add.s $f2, $f2, $f3     # b++
    j loop_ln

ret_ln:
    # stash b TODO nicer with store word
    mov.s $f9, $f2


    move $t0, $ra  # stash stack pointer
    mov.s $f12, $f1     # set arg = a
    jal ln0
    mov.s $f11, $f0     # temp = ln0(a)

    li.s $f12, 2.0     # set arg = 2
    jal ln0             # f0 = ln0(2)    

    mul.s $f0, $f9, $f0     # f0 = b * ln0(2)
    add.s $f0, $f11, $f0     # return = ln0(a) + b * ln0(2)

    jr $t0


#########       ln0         #########

# config:       $f3 = K
# arg:          $f12 = x
# internal:     $f1 = el, $f2 = i
# return:       $f0 = sum

ln0:
    li.s $f3, 10000.0             # K = 100

    li.s $f5, 1.0               # f5 = 1.0
    sub.s $f1, $f12, $f5        # el = x - 1.0
    
    li.s $f6, 0.0             # $f6 = 0
    add.s $f0, $f1, $f6         # sum = el

    li.s $f2, 2.0               # float i = 2

loop_ln0: 
    c.lt.s $f2, $f3             # c = (i < K)
    bc1f ret_ln0                  # if c return
    
    sub.s $f7, $f2, $f5         # f7 = i - 1
    mul.s $f1, $f1, $f7         # el = el * (i-1)

    sub.s $f8, $f5, $f12        # f8 = 1 - x
    div.s $f8, $f8, $f2         # f8 = (1 - x) / i
    mul.s $f1, $f1, $f8         # el = el * (1-x) / i

    add.s $f0, $f0, $f1         # sum += el

    add.s $f2, $f2, $f5         # i++

    j loop_ln0
   
ret_ln0:
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