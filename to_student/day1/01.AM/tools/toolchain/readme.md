# RISC-V toolchain
 - This toolchain references eecs151 fall coursework from UCB

## compress method
tar cvzf - riscv-toolchain-fa19 | split -b 40m - riscv-toolchain.tar

## decompress method
cat riscv-toolchain.tar* | tar xvzf -

## configure bin env
 - riscv64-unknown-elf-bin2hex: change LIBPATH
