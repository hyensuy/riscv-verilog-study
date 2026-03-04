.section    .start
.global     _start

_start:

  init :  
  	    li a2, 10
  	    li a3, 5
  	    li a4, 6
  	    
        add t0, a2, a3
        sub a1, t0, a4
