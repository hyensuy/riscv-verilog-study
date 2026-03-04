.section    .start
.global     _start

_start:
init:
        li a1, 10
        li a2, 5

        add a0, a1, a2

loop:
        j loop



