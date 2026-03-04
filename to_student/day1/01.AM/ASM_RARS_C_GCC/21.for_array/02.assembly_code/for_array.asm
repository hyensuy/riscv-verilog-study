.section    .start
.global     _start

_start: 
 init :
 	    la s0, words
 	    
            addi s1, zero, 0	#i = 0
            addi t2, zero, 10	#t2 = 10

  for:      
            bge  s1, t2, done   # if i >= 10 then done
            slli t0, s1, 2     	#t0 = i * 4(address)
            add  t0, t0, s0	#address of array 
            lw   t1, 0(t0)	#t1 = scores[i]
            addi t1, t1, 10	#t1 = scores[i] + 10
            sw   t1, 0(t0)	#scores[i] = t1
            addi s1, s1, 1	#i = i + 1
            j    for
  done:

.align 4
.data
 words: .word  1, 2, 3, 4, 5, 6, 7, 8, 9, 10
