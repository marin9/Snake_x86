#! /bin/bash

nasm -f bin snake.asm -o snake.bin
qemu-system-i386 -fda snake.bin

