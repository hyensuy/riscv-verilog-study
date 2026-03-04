.section    .start
.global     _start

 
  .equ N, 5

  .data
    A : .word 5, 42, -88, 2, -5033, 720, 314
    strl : .string "RISC-V"

  .align 2
    B : .word 0x32A

  .balign 4
  .text

_start:
            la   t0, A
            la   t1, strl
            la   t2, B
            la   t3, C
            la   t4, D
            lw   t5, N*4(t0)
            lw   t6, 0(t2)
            add  t5, t5, t6
            sw   t5, 0(t4)
            lb   t5, N-1(t1)
            sb   t5, 0(t4)
            la   t5, str2
            lb   t6, 8(t5)
            sb   t6, 0(t1)
            jr   ra

  .section .rodata
  str2: .string "Hello world!"
  .end
