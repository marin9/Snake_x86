# Snake game

Snake game in 512 Bytes.
Controls:
	A - left
	S - down
	D - right
	W - up
	R - restart

**Compile:**

```c
nasm -f bin snake.asm -o snake.bin
```

**Run in qemu:**

```c
qemu-system-i386 -fda snake.bin
```

![Snake screenshot](https://raw.githubusercontent.com/marin9/Snake_x86/master/ss.png)


