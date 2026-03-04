.section    .start
.global     _start

_start:

  init :  
  	    li s0, 10
  	    li s1, 5
  	    
            j target
            srai s1, s1, 2
            addi s1, s1, 1
            sub s1, s1, s0
target :    
            add s1, s1, s0
