###############################################################################
# Name:		Programming problem 6
#
# Description:	This program takes user input and counts the number of lowercase
#               vowels in each line, displaying the result.  
#
# Class:	CS354
#
# Written by:	Kristin Cox
# Section :	001
#
# Date:		12/3/12
###############################################################################

.data
prompt:       .asciiz  "Enter line:\n"
vowels:       .asciiz  " vowels\n"
description:  .asciiz  "Vowel counting program.\n"

.text

__start:
    sub   $sp, $sp, 8   # 2 word AR, for 2 parameters
main_loop:
    jal  readLine
    blt  $v0, $0, end        # if '\n' entered as first char, program ends
    add  $8, $0, $v0         # else print number of vowels in base 10
    li   $9, 10
    sw   $8, 4($sp)          # set parameters for function call
    sw   $9, 8($sp)          # set base to 10
    jal  print_integer
    puts vowels
    b    main_loop
end:
    done


###########################
# readLine:
# A function that displays an input prompt and waits for user input.  It 
# iterates through user entered characters until a '\n' is encountered.
# It counts the number of lowercase vowels in the user input and returns that
# value in $v0. If '\n' was the first user-entered character, it returns a -1.

readLine:
    # callee-saved registers
    sub  $sp, $sp, 16
    sw   $ra, 16($sp)
    sw   $8, 4($sp)
    sw   $9, 8($sp)
    sw   $10, 12($sp)

    li   $9, 0               # $9 holds count of lowercase vowels
    la   $10, prompt         # $10 holds prompt
    puts $10
    getc $8 
    beq  $8, 10, end_prog    # if encounter '\n' first, end program
while:                       # iterate through all characters
    beq  $8, 10, end_line    # if newline, line is over
    beq  $8, 97, add_one     # see if char matches any lowercase vowels
    beq  $8, 101, add_one
    beq  $8, 105, add_one
    beq  $8, 111, add_one
    beq  $8, 117, add_one
    getc $8
    b    while               # if no match, get next char and continue
add_one:                     # increment count if lowercase vowel encountered
    add  $9, $9, 1
    getc $8
    b    while               # get next char and continue

end_line:
    move $v0, $9
    b    restore

end_prog:
    li   $v0, -1             # return negative value to signal '\n' as first char

    # restore registers and return
restore:
    lw   $ra, 16($sp)
    lw   $8, 4($sp)
    lw   $9, 8($sp)
    lw   $10, 12($sp)
    add  $sp, $sp, 16
    jr   $ra


##################################
#print_integer:
# A function that takes two integer parameters: a number to print
# and a base in which to print the number.  The function then 
# prints the integer in the given base.  It does not return any 
# values in $v0.

print_integer:

   # prologue -- callee saves registers
   sub  $sp, $sp, 24
   sw   $ra, 24($sp)
   sw   $8, 4($sp)
   sw   $9, 8($sp)
   sw   $10, 12($sp)
   sw   $11, 16($sp)
   sw   $12, 20($sp)

   # $8 holds integer, $9 holds base
   lw   $8, 28($sp)
   lw   $9, 32($sp)
  
   add  $10, $8, $0          # check if integer is negative
   bge  $10, $0, positive
   li   $10, 45              # if negative, print '-'
   putc $10
   sub  $8, $0, $8           # convert to positive number for processing
positive:
   li   $11, 1               # $11 holds divisor
   #calculate base ^ (number characters - 1)      
get_divisor:                    
   div  $12, $8, $11         # $12 holds num/divisor to see if divisor done
   blt  $12, $9, got_divisor
   mul  $11, $11, $9          # multiply divisor by base if not big enough           
   b    get_divisor 
   # convert integer into a string to print
got_divisor:                 
   blt  $11, 1, converted    # while divisor is greater than 1
   div  $12, $8, $11         # divide current digit by divisor
   add  $12, $12, 48         # convert digit to ascii value
   putc $12                  # print out digits one by one
   rem  $8, $8, $11          # calculate int representing remaining digits
   div  $11, $11, $9         # divide divisor by base
   b    got_divisor
converted:   
   # epilogue -- restore registers and return
   lw   $8, 4($sp)          # restore register values
   lw   $9, 8($sp)
   lw   $10, 12($sp)
   lw   $11, 16($sp)
   lw   $12, 20($sp)
   lw   $ra, 24($sp)
   add  $sp, $sp, 24        # de-allocate AR space
   jr   $ra

    
