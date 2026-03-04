.section    .start
.global     _start

_start:
            addi s1, zero, 0 #s1 = sum
            addi s0, zero, 0 #s0 = i
            addi t0, zero, 10

  for:      bge  s0, t0, done      
            add  s1, s1, s0
            addi s0, s0, 1
            j    for
  done:

