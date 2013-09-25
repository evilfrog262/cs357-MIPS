# Kristin Cox, Section 1, CS 354
# Program reads input from the user, checks that the input is a valid integer,
# converts the input to an integer, and stores the integer.  It then prints out
# the integer.  Valid input includes negative and positive integers.  Any other
# input results in an error message and program termination.

.data
prompt: .asciiz "Enter value: "                # prompt for user input
error_msg: .asciiz "\nBad input. Quitting."    # error message for bad input
output: .asciiz "Value entered was "           # response message of input

.text
__start:     
       li   $8, 0               # $8 for loop induction variable i
       li   $9, 0               # $9 = 0 if positive input, 1 if negative
       li   $10, 6              # $10 for loop max constant              
       la   $11, prompt         # $11 string prompt
       li   $13, 0              # $13 integer translated from string input
       li   $14, 48             # $14 ascii value for '0'
       li   $15, 57             # $15 ascii value for '9'
       la   $16, error_msg      # $16 string error message
       li   $17, 10             # $17 ascii value of newline
       li   $18, 0              # $18 number of characters in input integer
       la   $20, output         # $20 string output message
       li   $21, 45             # $21 ascii value for '-'
       li   $22, 0              # $22 flag = 0 if entering leading 0's, else 1
for:         
       bge  $8, $10, endfor     # for loop reads in user input 6 times
       puts $11                 # prints prompt
       getc $12                 # $12 holds input characters
             
       bne  $12, 45, positive   # check if first character is '-'
       add  $9, $9, 1
       b    while
positive:    
       blt  $12, $14, error     # if not a '-' , check that it's a valid integer
       bgt  $12, $15, error
       beq  $12, 48, while      # if it is a leading 0, don't process it
       add  $22, $22, 1         # if it is not leading 0, set flag 

       sub  $12, $12, 48        # convert ascii value to integer value
       mul  $13, $13, 10        
       add  $13, $13, $12       
       add  $18, $18, 1         # increment count of characters             
while:      
       beq  $12, $17 endwhile   # loop while there are more characters 
       getc $12                 # get the next character
       # input validation
       beq  $12, $17, end_check # check for '\n' meaning end of entry
       blt  $12, $14, error     # if not a '\n', check that it's a valid integer
       bgt  $12, $15, error             
       beq  $22, 1, process     # if only encountered leading 0's, do check        
       beq  $12, 48, while      # if it is still a leading 0, get next input
       add  $22, $22, 1         # if it is not leading 0, set flag 
process:
       # conversion of string to positive integer
       sub  $12, $12, 48        # convert ascii value to integer value
       mul  $13, $13, 10        
       add  $13, $13, $12       
       add  $18, $18, 1         # increment count of characters
end_check:   
       b    while
endwhile:    
       puts $20                 # print results message
       # now $13 = integer, $18 = number of digits, $9 indicates negative
       li   $19, 1              # holds divisor
       sub  $18, $18, 1
get_divisor:                    # calculate base ^ (number characters - 1)
       blt  $18, 1, got_divisor 
       mul  $19, $19, 10        # multiply divisor by 10, (n -1) times  
       sub  $18, $18, 1         
       b    get_divisor
got_divisor:
       bne  $9, 1, convert      # skip printing '-' if positive number
       putc $21
convert:                        # convert integer back into a string
       blt  $19, 1, converted   # while divisor is greater than 1
       div  $12, $13, $19       # divide current digit by divisor
       add  $12, $12, 48        # convert digit to ascii value
       putc $12                 # print out digits one by one
       rem  $13, $13, $19       # calculate int representing remaining digits
       div  $19, $19, 10        # divide divisor by 10
       b    convert
converted:   
       putc $17                 # print a '\n' at end of line
       bne  $9, 1, clears       # skip if number is positive
       sub  $13, $0, $13        # if number was negative, convert to negative
clears:
       and  $9, $9, 0           # clear negative number indicator
       and  $18, $18, 0         # clear character count
       and  $22, $22, 0         # clear leading 0's flag
       add  $8, $8, 1
       b    for
endfor:      
       b    end                 # after 6 iterations, stop program     
error:       
       puts $16                 # if bad input, pring msg and exit
end: 
       done
