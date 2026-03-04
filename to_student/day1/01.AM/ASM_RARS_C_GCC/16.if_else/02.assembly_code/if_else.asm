.section    .start
.global     _start

_start:
  init :  
  	    li s0, 10
  	    li s1, 5
   	    li s4, 3
   	    
            bne s0, s1, L1
            add s2, s3, s4
            j   L2
  L1 :      sub s0, s1, s4
  L2 :
