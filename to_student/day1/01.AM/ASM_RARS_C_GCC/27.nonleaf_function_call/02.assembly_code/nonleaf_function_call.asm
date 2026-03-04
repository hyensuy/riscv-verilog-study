.section    .start
.global     _start

_start:
    init :  
  	    li a0, 3 #a0 = a, p 
  	    li a1, 1  #a1 = b
   	    
  	       
  function1 :  
            addi sp, sp, -12 
            sw   ra, 8(sp)
            sw   s4, -4(sp)
            sw   s5, 0(sp)
            add  s5, a0, a1
            sub  t3, a0, a1
            mul  s5, s5, t3
            addi s4, zero, 0	#i = 0 (init)

  for : 
            bge  s4, a0, return 
            addi sp, sp, -8 
            sw   a0, 4(sp)
            sw   a1, 0(sp)
            add  a0, a1, s4 
            jal  function2
            add  s5, s5, a0
            lw   a0, 4(sp)
            lw   a1, 0(sp)
            addi sp, sp, 8 
            addi s4, s4, 1
            j    for

  return : 
            add  a0, zero, s5 
            lw   ra, 8(sp)
            lw   s4, 4(sp)
            lw   s5, 0(sp)
            addi sp, sp, 12
            jr   ra

  function2 :  
            addi sp, sp, -4 
            sw   s4, 0(sp) 
            addi s4, a0, 5 
            add  a0, s4, a0
            lw   s4, 0(sp)
            addi sp, sp, 4
            jr   ra
