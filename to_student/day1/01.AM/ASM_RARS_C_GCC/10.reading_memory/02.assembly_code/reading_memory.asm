.section    .start
.global     _start

_start:
 init :
 	    la x1, words
 	    
            lw s7, 8(x1)

.align 4
.data
 words: .word 0, 5, 3