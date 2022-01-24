.globl __start

.rodata
    msg0: .string "This is HW1-1: T(n) = 2T(n/2) + 8n + 5, T(1) = 4\n"
    msg1: .string "Enter a number: "
    msg2: .string "The result is: "

.text
################################################################################
  # You may write function here
  
################################################################################

__start:
  # Prints msg0
    addi a0, x0, 4
    la a1, msg0
    ecall

  # Prints msg1
    addi a0, x0, 4
    la a1, msg1
    ecall

  # Reads an int
    addi a0, x0, 5
    ecall

################################################################################ 
  # Write your main function here. 
  # Input n is in a0. You should store the result T(n) into t0
  # HW1-1 T(n) = 2T(n/2) + 8n + 5, T(1) = 4, round down the result of division
  # ex. addi t0, a0, 1

jal x1,tfunc
jal x0,result

tfunc:       # n in a0, return tfunc(n) in t0
    addi  sp, sp, -8    # reserve our stack area
    sw x1, 0(sp)    # ra -> 0(sp) # save the return address
    addi t1,x0, 1        # t0 <- 1
    beq a0, t1, base_case # n=1 → a1 <- 4
    sw a0, 4(sp)    # n -> 4(sp)
    srli a0, a0, 1  # n <- n/2
    jal tfunc       # call tfunc(n/2)
                    # t0 <- tfunc(n/2)
    slli t0, t0, 1  # t0 <- 2t0 = 2tfunc(n/2)
    lw t1, 4(sp)    # t1 <- n
    slli t1, t1, 3  # t1 <- 8n
    add t0, t0, t1  # t0 += 8n
    addi t0, t0, 5  # t0 += 5
    jal x0, done

base_case:
    addi t0,x0, 4        # t0 <- 4 when n=1 # tfunc(1)=4

done:
    lw ra, 0(sp)    # ra <- ra # retore ra
    addi sp, sp, 8  # free our stack frame
    jalr x0,ra,0           # and return


  
    
    
################################################################################

result:
  # Prints msg2
    addi a0, x0, 4
    la a1, msg2
    ecall

  # Prints the result in t0
    addi a0, x0, 1
    add a1, x0, t0
    ecall
    
  # Ends the program with status code 0
    addi a0, x0, 10
    ecall