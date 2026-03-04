# If successful, it should write the value 4140 (0x102C) to address 216 (0xd8).
# RISC-V Assembly Description Address Machine Code
main: addi x2, x0, 5
      addi x3, x0, 12
      addi x7, x3, -9
      or x4, x7, x2
      and x5, x3, x4
      add x5, x5, x4
      sll x5, x5, x3
      srl x5, x5, x2
      bne x5, x3, skip
      sll x5, x5, x3
skip: beq x5, x7, end
      slt x4, x3, x4
      beq x4, x0, around
      addi x5, x0, 0
around: slt x4, x7, x2
      add x7, x4, x5
      sub x7, x7, x2
      sw x7, 200(x3)
      lw x2, 212(x0)
      add x9, x2, x5
      jal x3, end
      addi x2, x0, 1
end:  add x2, x2, x9
      addi x4, x0, -1
      addi x5, x0, 1
      addi x6, x0, 31
      sll x6, x5, x6
      xor x5, x4, x6
      slt x6, x5, x4
wrong: bne x6, x0, wrong
       xor x2, x2, x3
       sw x2, 0x84(x3)
done: beq x2, x2, done
