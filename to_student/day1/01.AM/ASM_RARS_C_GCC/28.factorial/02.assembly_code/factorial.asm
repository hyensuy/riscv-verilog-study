.section    .start
.global     _start

_start:
  init :  
  	    li a0, 5

  factorial:
            addi   sp, sp, -8
            sw     a0, 4(sp)
            sw     ra, 0(sp)
            addi   t0, zero, 1 
            bgt    a0, t0, else 
            addi   a0, zero, 1
            addi   sp, sp, 8
            jr     ra 

  else :
            addi   a0, a0, -1
            jal    factorial 
            lw     t1, 4(sp) 
            lw     ra, 0(sp) 
            addi   sp, sp, 8
            mul    a0, t1, a0
            jr     ra
