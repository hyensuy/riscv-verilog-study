.section    .start
.global     _start

_start:
  init :  
            addi a0, zero, 2     
            addi a1, zero, 3     
            addi a2, zero, 4     
            addi a3, zero, 5     

  diffofsums:
            addi sp, sp, -12
            sw   s3, 8(sp)
            sw   t0, 4(sp)
            sw   t1, 0(sp)
            add  t0, a0, a1
            add  t1, a2, a3
            sub  s3, t0, t1
            add  a0, s3, zero
            lw   s3, 8(sp) 
            lw   t0, 4(sp) 
            lw   t1, 0(sp) 
            addi sp, sp, 12 
            jr   ra
