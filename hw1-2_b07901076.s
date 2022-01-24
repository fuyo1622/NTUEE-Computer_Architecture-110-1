.globl __start

.rodata
    msg0: .string "This is HW1-2: \n"
    msg1: .string "Plaintext:  "
    msg2: .string "Ciphertext: "
.text

################################################################################
  # print_char function
  # Usage: 
  #     1. Store the beginning address in x20
  #     2. Use "j print_char"
  #     The function will print the string stored from x20 
  #     When finish, the whole program with return value 0

print_char:
    addi a0, x0, 4
    la a1, msg2
    ecall
    
    add a1,x0,x20
    ecall

  # Ends the program with status code 0
    addi a0,x0,10
    ecall
    
################################################################################

__start:
  # Prints msg
    addi a0, x0, 4
    la a1, msg0
    ecall

    la a1, msg1
    ecall
    
    addi a0,x0,8
    li a1, 0x10130
    addi a2,x0,2047
    ecall
    
  # Load address of the input string into a0
    add a0,x0,a1

################################################################################ 
  # Write your main function here. 
  # a0 stores the begining Plaintext
  # Do store 66048(0x10200) into x20 
  # ex. j print_char
addi sp, sp, -8
sw  x25,0(sp)
add x25,x0,x0
addi x21, x0, 48 # record space
addi x22, x0, 32
addi x23, x0, 119
addi x24, x0, 23
L1:
    add x5,x25,a0
    lbu x6,0(x5)
    mv x19, x6
    beq x19,x0,L2
cipher:
    beq x19, x22, exit1
    blt x23, x19, exit2
    addi x19, x19, 3
    beq x0, x0, exit
exit1:
    mv x19, x21
    addi x21, x21, 1
    beq x0, x0, exit
exit2:
    sub x19, x19, x24
exit:
    addi x5,x5,208
    sb x19,0(x5)
    addi x25,x25,1
    jal x0,L1
L2:
    lw  x25,0(sp)
    addi sp,sp,8
    addi sp,sp,-8
    sw x25,0(sp)
    add x25,x0,x0
    add x20,x25,a0
    addi x20,x20,208
    j print_char
    
    
################################################################################

