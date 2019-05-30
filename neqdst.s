# Start with data declarations
#
.data 
n_prompt: .asciiz "Enter N: "
xmin_prompt: .asciiz "Enter x_min: "
xmax_prompt: .asciiz "Enter x_max: "
done_prompt: .asciiz " Done [0 = Yes, 1 = No]: "
newline: .asciiz "\n"
zero: .float 0.0

.align 2

z:  .word 4

xmin: .word 0
xmax: .word 0

.globl main			# leave this here for the moment
.text			

main:
    lwc1 $f3, zero # initialize global zero

    # Print N Prompt
    la  $a0, n_prompt
    jal prompt

    # Read N
    jal read_int
    move $t0, $v0   # t0 = n

    # Print xmin Prompt
    la  $a0, xmin_prompt
    jal prompt

    # Read xmin
    jal read_float
    mov.s $f2, $f0  # f2 = xmin
    # TODO store xmin

    # Print xmax Prompt
    la  $a0, xmax_prompt
    jal prompt

    # Read xmax
    jal read_float
    mov.s $f3, $f0  # f3 = xmax
    # TODO store xmax

    # Check Input
    c.le.s $f3, $f2 # if xmin >= xmax finish
    bc1t fin

    # Calculate equidistance
    sub.s $f4, $f3, $f2
    div.s $f4, $f4, $t0 # f4 = (xmax - xmin) / n

    add.s $f5, $0, $f2  # x = f5 = xmin

loop:
    c.lt.s $f5, $f3     # while (x < xmax)
    bc1f end
    
    # store x

    # y = exp(x)
    mov.s $f12, $f5
    li $a1, 6
    jal exp
    # store y

    # z = ln(y)
    mov.s $f12, $f0
    jal ln
    # store z
    
    add.s $f5, $f5, $f4 # x += dist
    j loop

end:

    # print y's and z's



    # Store Result
    s.s $f0, z

    # Print Function Result
    mov.s $f12, $f0    # move $f0 to $f12
    jal print_float

fin:
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
    move $t4, $ra  # stash stack pointer

power_loop:

    li $t1, 0
    ble $a2, $t1, power_ret  # branch if exponent <= 0
    mul.s $f2, $f2, $f12
    addi $a2, $a2, -1

    j power_loop

power_ret:
    add.s $f0, $f2, $f3 # copy f2 to f0
    jr $t4


#########       fact         #########

# args:         $a2 = x
# return:       $v0 = fact(i)

fact:
    li $t2, 1 # i
    move $t5, $ra  # stash stack pointer

    li $v0, 1 # result

fact_loop:

    bgt $t2, $a2, fact_ret  # branch if i > parameter

    mul $v0, $v0, $t2
    addi $t2, $t2, 1

    j fact_loop

fact_ret:
    jr $t5




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