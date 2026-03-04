.section    .start
.global     _start

_start:
  init :  
  	    li s0, 5
  	    li s1, 5
  	    li s3, 6
   	    li s4, 3
   	     	    
            bne s0, s1, L1
            add s2, s3, s4
  L1 :      sub s0, s1, s4
