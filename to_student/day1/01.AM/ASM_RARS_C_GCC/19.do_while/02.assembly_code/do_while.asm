.section    .start
.global     _start

_start:
            addi s0, zero, 1
            add  s1, zero, zero

            addi t0, zero, 128 
  while:            
            slli s0, s0, 1
            addi s1, s1, 1
            bne  s0, t0, while
  done:

