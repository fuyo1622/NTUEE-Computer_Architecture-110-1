.data
    n: .word 10
    
.text
.globl __start

FUNCTION:
    # Todo: Define your own function in HW1
    addi  sp, sp, -8    # reserve our stack area
    sw x1, 0(sp)    # ra -> 0(sp) # save the return address
    addi t1,x0, 1        # t0 <- 1
    beq a0, t1, base_case # n=1 → a1 <- 4
    sw a0, 4(sp)    # n -> 4(sp)
    srli a0, a0, 1  # n <- n/2
    jal FUNCTION       # call tfunc(n/2)
                    # t0 <- tfunc(n/2)
    slli t0, t0, 1  # t0 <- 2t0 = 2tfunc(n/2)
    lw t1, 4(sp)    # t1 <- n
    slli t1, t1, 3  # t1 <- 8n
    add t0, t0, t1  # t0 += 8n
    addi t0, t0, 5  # t0 += 5
    addi x10,t0,0
    jal x0,done


base_case:
    addi t0,x0, 4        # t0 <- 4 when n=1 # tfunc(1)=4

done:
    lw ra, 0(sp)    # ra <- ra # retore ra
    addi sp, sp, 8  # free our stack frame
    jalr x0,ra,0    

# Do NOT modify this part!!!
__start:
    la   t0, n
    lw   x10, 0(t0)
    jal  x1,FUNCTION
    la   t0, n
    sw   x10, 4(t0)
    addi a0,x0,10
    ecall