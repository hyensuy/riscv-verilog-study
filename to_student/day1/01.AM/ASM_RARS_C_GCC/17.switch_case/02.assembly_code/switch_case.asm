.section    .start
.global     _start

_start:
  init :  
  	    li s0, 2
  	    
  case1 :    
            addi t0, zero, 1
            bne  s0, t0, case2
            addi s1, zero, 20
            j   done

  case2 :
            addi t0,zero, 2
            bne  s0, t0, case3
            addi s1, zero, 50
            j   done

  case3 : 
            addi t0,zero, 3
            bne  s0, t0, default
            addi s1, zero, 100
            j   done

  default :
            add s1, zero, zero

  done:

