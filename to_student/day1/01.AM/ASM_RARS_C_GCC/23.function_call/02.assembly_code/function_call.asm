.section    .start
.global     _start

_start:
            addi a0, zero, 2     
            addi a1, zero, 3     
            addi a2, zero, 4     
            addi a3, zero, 5     
            jal  diffofsums
            add  s7, a0, zero   #s7 = y
            
  diffofsums:
            add t0, a0, a1	# 2 + 3 = 5
            add t1, a2, a3	# 4 + 5 = 9
            sub s3, t0, t1	# 5 - 9 = -4
            add a0, s3, zero
            jr  ra
