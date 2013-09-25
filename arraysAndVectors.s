# Name and section: Kristin Cox, Section 001

# This program reads in 6 integers, placing them into two arrays of
# 3 elements each.  Each array represents a vector.
# Given these vectors, the program computes and prints a dot product
# and a vector product.

.data
VECTOR_SIZE:    .word   3

str_prompt1:    .asciiz "Enter value: "
msg_out1:       .asciiz "dot product:  "
msg_out2:       .asciiz "\ncross product:\n"
msg_out3:       .asciiz "i - "
msg_out4:       .asciiz "j + "
msg_out5:       .asciiz "k\n"
vector1:        .word   0:3
vector2:        .word   0:3
vector3:        .word   0:3
str_badinput:   .asciiz "\nBad input.  Quitting.\n"	
newline:        .asciiz "\n"	


 .text
__start:        
   sub  $sp, $sp, 16             # 4 parameters (max) passed from main()
                                 #   so allocate stack space for them
   # getVectors will read all 6 integers, or returns 0 if there was an
   # error in user input
   la   $8, vector1              # P1 to getVectors is vector1 base addr
   sw   $8, 4($sp)
   la   $9, vector2              # P2 to getVectors is vector2 base addr
   sw   $9, 8($sp)
   lw   $10, VECTOR_SIZE         # P3 to getVectors is 3, vector's size 
   sw   $10, 12($sp)
   jal  getVectors
   beqz $v0, bad_input           # return value is 0 for bad input

   # compute and print dot product
   sw   $8, 4($sp)              # same parameters to dotProduct
   sw   $9, 8($sp)
   sw   $10, 12($sp) 
   jal  dotProduct
   sw   $v0, 4($sp)              # P1 to print_integer is the integer
   puts msg_out1
   li   $11, 10                  # P2 is base to print in:  10
   sw   $11, 8($sp)
   jal  print_integer

   # compute and print cross product
   sw   $8, 4($sp)              # P1 to crossProduct is vector1 base addr
   sw   $9, 8($sp)              # P2 to crossProduct is vector2 base addr
   la   $11, vector3
   sw   $11, 12($sp)            # P3 to crossProduct is vector3 base addr
   sw   $10, 16($sp)            # P4 to crossProduct is vector size (3)
   jal  crossProduct
   puts msg_out2                # print cross product
   lw   $12, ($11)              # print vector3[0]
   sw   $12, 4($sp)             # P1 to print_integer is the integer
   li   $13, 10                 # print decimal representation
   sw   $13, 8($sp)             # P2 to print_integer is the radix
   jal  print_integer
   puts msg_out3
   lw   $12, 4($11)              # print vector3[1]
   sw   $12, 4($sp)             # P1 to print_integer is the integer
   sw   $13, 8($sp)             # P2 to print_integer is the radix
   jal  print_integer
   puts msg_out4
   lw   $12, 8($11)              # print vector3[2]
   sw   $12, 4($sp)             # P1 to print_integer is the integer
   sw   $13, 8($sp)             # P2 to print_integer is the radix
   jal  print_integer
   puts msg_out5

   b    end_program

bad_input:  
   puts str_badinput
   b    end_program

end_program:    
   add  $sp, $sp, 16
   done


####################
# getVectors
# Takes three parameters: two array addresses and an integer array size.
# Prompts the user for integer input 6 times.  Calls get_integer() to read
# user input.  Stores the first 3 integers in one array and the second 3 
# integers in a second array.  If bad input is encountered, the function
# exits and returns the value 0 in $v0.

getVectors:

       # prologue -- callee saves used registers
       sub  $sp, $sp, 20
       sw   $ra, 20($sp)
       sw   $8, 4($sp)
       sw   $9, 8($sp)
       sw   $10, 12($sp)
       sw   $11, 16($sp)

       # load values for necessary registers
       li   $8, 0               # holds induction variable for outer loop
       li   $9, 2               # holds sentinel value for outer loop
                                # $10 serves as pointer to correct array
       la   $11, str_prompt1    # holds user prompt message
       
       # begin processing user input
       lw   $10, 24($sp)        # $10 is a pointer to the first vector
forout:                         # get three values for first vector
       bgt  $8, $9, clear
       puts $11                 # prompt user to enter value
       jal  get_integer         # call get_integer() to process user input
       blt  $v1, $0, error      # if input was invalid, process error
       sw   $v0, ($10)          # store value in first array index
       add  $10, $10, 4         # increment to next array index
       add  $8, $8, 1           # increment induction variable
       b forout      
clear:
       and  $8, $8, $0          # clear induction variable
       lw   $10, 28($sp)        # $10 is now a pointer to the 2nd array
forout2:
       bgt  $8, $9, endforout
       puts $11                 # prompt user to enter value
       jal  get_integer         # call get_integer() to process user input
       blt  $v1, $0, error      # if input was invalid, process error
       sw   $v0, ($10)          # store value in first array index
       add  $10, $10, 4         # increment to next array index
       add  $8, $8, 1           # increment induction variable
       b forout2      
endforout:
       li   $v0, 1
       b    epilogue             # if good input, return 1
error:
       li   $v0, 0               # if bad input, return 0
epilogue:
       lw   $ra, 20($sp)         # restore register contents
       lw   $8, 4($sp)
       lw   $9, 8($sp)
       lw   $10, 12($sp)
       lw   $11, 16($sp)
       add  $sp, $sp, 20         # deallocate AR space
       jr   $ra

####################
#dotProduct
# Receives three parameters: two array addresses and an integer array size. 
# Computes the dot product of the vectors stored in the given arrays and
# returns this integer value in $v0.  Does not return any values.

dotProduct:
       
       # prologue -- callee saves registers
       sub  $sp, $sp, 28
       sw   $ra, 28($sp)
       sw   $8, 4($sp)
       sw   $9, 8($sp)
       sw   $10, 12($sp)
       sw   $11, 16($sp)
       sw   $12, 20($sp)
       sw   $13, 24($sp)

       # calculate the dot product from the given vectors
       lw   $8, 32($sp)         # address of vector 1
       lw   $9, 36($sp)         # address of vector 2
       lw   $10, ($8)           # holds first integer value u1
       lw   $11, ($9)           # holds first integer value v1
       mul  $12, $10, $11       # holds the product u1*v1
       lw   $10, 4($8)          # holds the second integer value u2
       lw   $11, 4($9)          # holds the second integer value v2
       mul  $13, $10, $11       # holds the product u2*v2
       lw   $10, 8($8)          # holds the third integer value u3
       lw   $11, 8($9)          # holds the third integer value v3
       mul  $14, $10, $11       # holds the product u3*v3
       add  $12, $12, $13
       add  $12, $12, $14       # $12 now holds the final dot product

       move $v0, $12

       # epilogue
       lw   $ra, 28($sp)         # restore register contents
       lw   $8, 4($sp)
       lw   $9, 8($sp)
       lw   $10, 12($sp)
       lw   $11, 16($sp)
       lw   $12, 20($sp)
       lw   $13, 24($sp)
       add  $sp, $sp, 28         # deallocate AR space
       jr   $ra

####################
#crossProduct
# Receives four parameters: three array addresses and an integer array size. 
# Computes the cross product of the two vectors stored in the first two
# provided addresses.  Stores the resulting vector in the third provided 
# address.  Does not return any values.

crossProduct:

       # prologue -- callee saves registers
       sub  $sp, $sp, 48
       sw   $ra, 48($sp)
       sw   $8, 4($sp)
       sw   $9, 8($sp)
       sw   $10, 12($sp)
       sw   $11, 16($sp)
       sw   $12, 20($sp)
       sw   $13, 24($sp)
       sw   $14, 28($sp)
       sw   $15, 32($sp)
       sw   $16, 36($sp)
       sw   $17, 40($sp)
       sw   $18, 44($sp)

       # calculate the cross product
       lw   $8, 52($sp)
       lw   $9, 56($sp)
       lw   $18, 60($sp)
       lw   $10, ($8)           # holds u1
       lw   $11, 4($8)          # holds u2
       lw   $12, 8($8)          # holds u3
       lw   $13, ($9)           # holds v1
       lw   $14, 4($9)          # holds v2
       lw   $15, 8($9)          # holds v3
       mul  $16, $11, $15       # u2*v3
       mul  $17, $12, $14       # u3*v2
       sub  $16, $16, $17       # holds (u2*v3 - u3*v2)
       sw   $16, ($18)          # store value 1 in array
       add  $18, $18, 4
       mul  $16, $10, $15       # u1*v3
       mul  $17, $12, $13       # u3*v1
       sub  $16, $16, $17       # holds (u1*v3 - u3*v1)
       sw   $16, ($18)          # store value 2 in array
       add  $18, $18, 4
       mul  $16, $10, $14       # u1*v2
       mul  $17, $11, $13       # u2*v1
       sub  $16, $16, $17       # holds (u1*v2 - u2*v1)
       sw   $16, ($18)          # store value 3 in array

       # epilogue
       lw   $ra, 48($sp)        # restore register values
       lw   $8, 4($sp)
       lw   $9, 8($sp)
       lw   $10, 12($sp)
       lw   $11, 16($sp)
       lw   $12, 20($sp)
       lw   $13, 24($sp)
       lw   $14, 28($sp)
       lw   $15, 32($sp)
       lw   $16, 36($sp)
       lw   $17, 40($sp)
       lw   $18, 44($sp)
       add  $sp, $sp, 48        # deallocate AR space
       jr  $ra


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

####################
#get_integer: 
# A function that reads in, and returns a user-integer in $v0.
# A badly formed integer leads to a negative return value in $v1.
# A well-formed integer has an optional '-' character followed by
# digits '0'-'9', and is ended with the newline character.

get_integer:
   sub  $sp, $sp, 24         # allocate AR
   sw   $ra, 24($sp)         # save registers in AR
   sw   $8,  4($sp)
   sw   $9,  8($sp)
   sw   $10, 12($sp)
   sw   $11, 16($sp)
   sw   $12, 20($sp)

   li   $10, 0               # $10 is the calcuated integer
   li   $v1, 0               # assume int is good
   li   $12, 0               # $12 is now flag, 1 means negative
                             #  and 0 means not negative
   getc $8                   # $8 holds 1 user-entered character 
   li   $11, '-'             # check if 1st character is '-'
   bne  $8, $11, notneg
   li   $12, 1               # is negative
   getc $8                   
notneg:
   li   $9, 10               # check if 1st character is newline
   beq  $8, $9, not_good_int

gi_while_1:
   li   $9, 10               # check if character is newline
   beq  $8, $9, gi_finish

   li   $9, 48               # $9 is the ASCII character '0'
   blt  $8, $9, not_good_int
   sub  $8, $8, $9           # $8 is now 2's comp rep that is >= 0

   li   $9, 10               # $9 is now the constant 10
   bge  $8, $9, not_good_int
	 
   mul  $10, $10, $9         # int = ( int * 10 ) + digit
   add  $10, $10, $8
         
   getc $8
   b    gi_while_1           # loop to get more digits

not_good_int:  
   li   $v1, -1	             # return value = -1 for bad int
   b    gi_epilogue

gi_finish: 
   beqz $12, gi_epilogue 
   mul  $10, $10, -1
gi_epilogue: 
   move $v0, $10             # set return value in its proper register
   lw   $8,  4($sp)          # restore register values
   lw   $9,  8($sp)
   lw   $10, 12($sp)
   lw   $11, 16($sp)
   lw   $12, 20($sp)
   lw   $ra, 24($sp)
   add  $sp, $sp, 24         # deallocate AR space
   jr   $ra                  # return
