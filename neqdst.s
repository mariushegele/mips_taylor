# Start with data declarations
#
.data 
n_prompt: .asciiz "Enter N: "
xmin_prompt: .asciiz "Enter x_min: "
xmax_prompt: .asciiz "Enter x_max: "
done_prompt: .asciiz " Done [0 = Yes, 1 = No]: "

newline: .asciiz "\n"
tab: .asciiz "\t"
header: .asciiz "x\t\te(x)\t\tln(e(x))\n"

.align 2

constK: .float 1000.0
const0: .float 0.0
const1: .float 1.0
const10: .float 10.0


z:  .word 4

xmin: .word 0
xmax: .word 0

.globl main			# leave this here for the moment
.text			

#########       main         #########

# internal:     $t0 = n = 0($sp), $f2 = xmin = 4($sp), $f3 = xmax = 8($sp), 
#               $f4 = dist = 12($sp), $f5 = x = 16($sp), e(x) = 20($sp)
# constants:    $f6 = 0

main:
    # Store intermediate values on stack -> reserve space
    addi $sp, $sp, -24

    # Print N Prompt
    la  $a0, n_prompt
    jal prompt

    # Read N
    jal read_int
    move $t0, $v0   # t0 = n
    sw $t0, 0($sp)


    # Print xmin Prompt
    la  $a0, xmin_prompt
    jal prompt

    # Read xmin
    jal read_float
    mov.s $f2, $f0  # f2 = xmin
    s.s $f2, 4($sp) # store xmin

    # Print xmax Prompt
    la  $a0, xmax_prompt
    jal prompt

    # Read xmax
    jal read_float
    mov.s $f3, $f0  # f3 = xmax
    s.s $f3, 8($sp) # store xmax

    # Check Input
    c.le.s $f3, $f2 # if xmin >= xmax (error) -> prompt redo
    bc1t end

    # Print Table Headers: x \t e(x) \t ln(e(x))
    la $a0, header	# print the new line character to force a carriage return 
	li $v0, 4		# on the console
	syscall

    # Calculate equidistance

    lw $t0, 0($sp)       # restore n
    mtc1 $t0, $f0
    cvt.s.w $f0, $f0

    sub.s $f4, $f3, $f2  # xmax - xmin
    lwc1 $f5, const1
    add.s $f4, $f4, $f5  # xmax - xmin + 1
    div.s $f4, $f4, $f0  # f4 = (xmax - xmin + 1) / n
    s.s $f4, 12($sp)     # store dist

    mov.s $f5, $f2      # x = f5 = xmin
    s.s $f5, 16($sp)    # store x

loop:
    l.s $f6, const0
    add.s $f12, $f6, $f5    # copy x into argument
    jal printf_float_oneline

    
    mov.s $f12, $f5
    jal opt_terms # determine optimal number of terms
    mov.s $f13, $f0

    # y = exp(x)
    jal exp
    s.s $f0, 20($sp)   # store e(x)
    # print e(x)
    mov.s $f12, $f0
    jal printf_float_oneline


    # z = ln(y)
    l.s $f12, 20($sp)   # restore e(x)
    jal ln
    # print ln(e(x))
    mov.s $f12, $f0
    jal printf_float_oneline
    
    l.s $f4, 12($sp)     # restore dist
    l.s $f5, 16($sp)    # restore x
    add.s $f5, $f5, $f4 # x += dist
    s.s $f5, 16($sp)    # store x

    la $a0, newline	# print the new line character
	li $v0, 4
	syscall

    l.s $f3, 8($sp)     # restore xmax
    l.s $f5, 16($sp)    # restore x
    c.le.s $f5, $f3     # while (x <= xmax)
    bc1t loop
    

end:
    la $a0, newline # print new line
    li $v0, 4
    syscall
    
    addi $sp, $sp, 24   # free up stack space

    # Prompt if Done
    jal prompt_redo



#########       ln        #########

# arg:          $f12 = x
# internal:     $f1 = a, $f2 = b
# return:       $f0 = ln0(0) + b * ln0(2)

ln:
    mov.s $f1, $f12         # a = x
    li.s $f2, 0.0           # b = 0

    li.s $f3, 1.0
    li.s $f4, 2.0
    
loop_ln: 
    c.le.s $f1, $f4         # (a <= 2)? return : loop
    bc1t ret_ln

    div.s $f1, $f1, $f4        # a = a / 2
    
    add.s $f2, $f2, $f3     # b++
    j loop_ln

ret_ln:
    addi $sp, $sp, -12
    sw $ra, 0($sp)     # store return address
    s.s $f2, 4($sp)    # store b

    mov.s $f12, $f1     # set arg = a
    jal ln0             # y = ln0(a)
    s.s $f0, 8($sp)     # store ln0(a)

    li.s $f12, 2.0      # set arg = 2
    jal ln0             # f0 = ln0(2)

    # restore values
    lw $ra, 0($sp)
    l.s $f2, 4($sp)
    l.s $f5, 8($sp)         # f5 = ln0(a)

    mul.s $f0, $f2, $f0     # f0 = b * ln0(2)
    add.s $f0, $f5, $f0     # return = ln0(a) + b * ln0(2)

    addi $sp, $sp, 12       # free up stack space

    jr  $ra


#########       ln0         #########

# config:       $f3 = K
# arg:          $f12 = x
# internal:     $f1 = el, $f2 = i
# return:       $f0 = sum

ln0:
    l.s $f3, constK             # K = 100

    li.s $f5, 1.0               # f5 = 1.0
    sub.s $f1, $f12, $f5        # el = x - 1.0
    
    li.s $f6, 0.0               # $f6 = 0
    add.s $f0, $f1, $f6         # sum = el

    li.s $f2, 2.0               # float i = 2

loop_ln0: 
    c.lt.s $f2, $f3             # c = (i < K)
    bc1f ret_ln0                # if c return
    
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

printf_float_oneline:
    li      $v0, 2 # print float in $f12
    syscall
    
    l.s $f11, const10
    c.lt.s $f12, $f11
    bc1f only_one_tab

    la $a0, tab	    # print the tab character
	li $v0, 4		# on the console
	syscall

only_one_tab:
	la $a0, tab	    # print the tab character
	li $v0, 4		# on the console
	syscall

    jr $ra


print_float:
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