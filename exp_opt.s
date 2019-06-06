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
zero: .float 0.0

.align 2

z: .word 4
btemp: .word 4
exptemp: .word 4

.globl main
.text			

main:
    ########## Print X-Prompt ###########
    la      $a0, x_prompt
    jal     print
    #####################################

    ########## Read X from user ###########
    jal     read_float
    mov.s   $f12, $f0  # set read float as arg
    #######################################

    # TODO: ask for n(iterations)
    li $a1, 10
    lwc1 $f6, zero # global zero

    # Execute Function
    jal exp

    ########## Print After-Exp-Loop-Print ###########
    #la  $a0, expafterprint
    #jal print
    #################################################


    # Store Result
    s.s $f0, z

    # Print Function Result
    mov.s $f12, $f0    # move $f0 to $f12
    jal print_result

    # Prompt if Done
    jal prompt_redo


#########      exp       #########

# arg:          $f12 = x // TODO: $a1 = n
# internal:     $f1 = result, $f2 = power, $f3 = factorial, $f4 = i in float, $f5 = 'part'(power/fact)
#               $f13 = saveplace for $f12 (for prints)
# return:       $f0 = 

exp:
    li.s $f1, 0.0           # result = 0.0
    li.s $f2, 1.0           # power = 1.0
    li.s $f3, 1.0           # fact = 1.0
    li $t0, 0               # i = 0
    move $t3, $ra           # stash stack pointer

    ########## Print initial x ###########
    #jal print_float
    ###################################
exp_loop:
    bge $t0, $a1, exp_ret # if i>=n jump out of loop
    
    ########## Print Exp-Loop-Print ###########
    #la      $a0, exploopprint
    #jal print
    ###################################


    ########## Print Power ###########
    #add.s $f13, $f12, $f6   # save $f12
    #add.s $f12, $f2, $f6    # prepare $f2 to be printed
    #jal print_float
    #add.s $f12, $f13, $f6   # restore $f12
    ###################################

    ########## Print x ###########
    #jal print_float
    ###################################


    beq $t0, $zero, partcal # ignore changes to factorial and power if i = 0

    mul.s $f2, $f2, $f12    # power = power * x

    ########## Print Power ###########
    #add.s $f13, $f12, $f6  # print power
    #add.s $f12, $f2, $f6
    #jal print_float
    #add.s $f12, $f13, $f6
    ###################################

    mtc1 $t0, $f4           # move i to a float register
    cvt.s.w $f4, $f4        # convert i to a float for following operation
    mul.s $f3, $f3, $f4     # fact = fact * i

partcal:
    div.s $f5, $f2, $f3 # power/fact
    
    ########## Print Part ###########
    #add.s $f13, $f12, $f6  # print part
    #add.s $f12, $f5, $f6 
    #jal print_float
    #add.s $f12, $f13, $f6
    ###################################

    add.s $f1, $f1, $f5 # result += part
    addi $t0, $t0, 1
    j exp_loop

exp_ret:

    ########## Print Prompt ###########
    #la         $a0, expreturnprint
    #jal print
    ###################################

    add.s $f0, $f1, $f6
    jr $t3


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

