# Start with data declarations
#
.data 
x_prompt: .asciiz "Enter x: "
n_prompt: .asciiz "How many iterations should I run(n): "
debugprint: .asciiz "heyo"
exploopprint: .asciiz "\nIn EXP-Loop "
powerloopprint: .asciiz "In Power-Loop"
factloopprint: .asciiz " In Fact-Loop, i = "
expreturnprint: .asciiz " In EXP-Return"
powerreturnprint: .asciiz "In Power-Return.\n\tZähler: "
factreturnprint: .asciiz " In Fact-Return.\n\tNenner: "
expafterprint: .asciiz "After EXP"
powerafterprint: .asciiz " After Power"
factafterprint: .asciiz " After Fact.\n\tPart: "
zaehlerprint: .asciiz "Zähler: "
nennerprint: .asciiz "Nenner: "
partprint: .asciiz "Part: "
factinprint: .asciiz "Entered Fact, parameter: "
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
    li.s $f7, 0.0 # global zero
    li.s $f8, 1.0 # global one
    ########## Print X-Prompt ###########
    la      $a0, x_prompt
    jal     print
    #####################################

    ########## Read X from user ###########
    jal     read_float
    mov.s   $f12, $f0  # set read float as arg
    #######################################

    li.s $f13, 34.0   # possible iterations
    li.s $f2, 14.0    # $f2 = 14
    c.lt.s $f12, $f2  # parameter < 14
    bc1t parameter_set  # jump if (parameter less than 14)

    li.s $f3, 10.0    # $f3 = 10
    add.s $f13, $f12, $f3   # $f13 = parameter + 10

    li.s $f3, 400.0   # $f3 = 400
    div.s $f13, $f3, $f13   # $f13 = 400 / $f13

    add.s $f13, $f13, $f2

parameter_set:

    # Execute Function
    jal exp

    ########## Print After-Exp-Loop-Print ###########
    #la  $a0, expafterprint
    #jal print
    #################################################

    # Store Result
    s.s $f0, z

    ########## Print Function Result ###########
    mov.s $f12, $f0    # move $f0 to $f12
    jal print_result
    ############################################

    # Prompt if Done
    jal prompt_redo


#########      exp       #########

# arg:          $f12 = x, $f13 = n
# internal:     $f0 = result, $f2 = power, $f3 = factorial, $f4 = i, $f5 = 'part'(power/fact)
#               $f6 = saveplace for $f12 (for prints), $f7 = zero, $f8 = 1.0
# return:       $f0 = result

exp:
    li.s $f0, 0.0           # result = 0.0
    li.s $f2, 1.0           # power = 1.0
    li.s $f3, 1.0           # fact = 1.0
    li.s $f4, 0.0             # i = 0
    move $t3, $ra           # stash stack pointer

    ########## Print initial x ###########
    #jal print_float
    ###################################
exp_loop:
    c.le.s $f13, $f4 # n<=i
    bc1t exp_ret  # if n<=i jump out of loop

    
    ########## Print Exp-Loop-Print ###########
    #la      $a0, exploopprint
    #jal print
    ###################################


    ########## Print Power ###########
    #add.s $f6, $f12, $f7   # save $f12
    #add.s $f12, $f2, $f7    # prepare $f2 to be printed
    #jal print_float
    #add.s $f12, $f6, $f7   # restore $f12
    ###################################

    ########## Print x ###########
    #jal print_float
    ###################################

    c.eq.s $f4, $f7 # ignore changes to factorial and power if i = 0
    bc1t partcal  # jump if i = 0


    mul.s $f2, $f2, $f12    # power = power * x

    ########## Print Power ###########
    #add.s $f6, $f12, $f7  # print power
    #add.s $f12, $f2, $f7
    #jal print_float
    #add.s $f12, $f6, $f7
    ###################################

    mul.s $f3, $f3, $f4     # fact = fact * i

partcal:
    div.s $f5, $f2, $f3 # power/fact
    
    ########## Print Part ###########
    #add.s $f6, $f12, $f7  # print part
    #add.s $f12, $f5, $f7 
    #jal print_float
    #add.s $f12, $f6, $f7
    ###################################

    add.s $f0, $f0, $f5 # result += part
    add.s $f4, $f4, $f8    # i++
    j exp_loop

exp_ret:

    ########## Print Prompt ###########
    #la         $a0, expreturnprint
    #jal print
    ###################################

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

