org 	0x7C00
bits	16

start:
	; init resisters
	xor ax, ax
	mov ds, ax
	mov ss, ax
	mov sp, 0x7b00

	; set video mod 40x25
	xor ax, ax
	int 0x10

	; disable cursor
	mov ch, 0x3f
	mov ah, 0x01
	int 0x10

loop:
	call clear_screen
	; check keyboard buffer status
	mov ah, 1
	int 0x16
	je no_key
	; get key
	mov ah, 0	
	int 0x16
	mov [ort], al
no_key:
	call test_collision
	call move_snake
	call eat_food
	call draw_scores
	call draw_food
	call draw_snake
	; sleep
	mov ah, 0x86
	mov cx, 0x0001
	mov dx, 0xC000	
	mov bx, [score]
	cmp bx, 50
	jl _d
	; sleep less if score >= 50
	dec cl
_d:	int 0x15
	jmp loop


clear_screen:
	mov ax, 0x0700	; scroll down window
	mov bh, 0x20	; black on green
	xor cx, cx		; specifies top left of screen as (0,0)
	mov dx, 0x1827	; 18h=24 rows, 27h=39 cols
	int 0x10
	ret

draw_scores:
	; set cursor (0, 0)
	mov bh, 0x00
	xor dx, dx
	mov ah, 0x02
	int 0x10
	; draw black line on top
	mov ax, 0x0900
	mov bl, 0x0e
	mov cx, 40
	int 0x10
	; set cursor (0, 0)
	mov bh, 0x00
	xor dx, dx
	mov ah, 0x02
	int 0x10
	; score number to string
_3:	mov ax, [score]
	mov bx, 10
	xor cx, cx
_4:	xor dx, dx
	div bx
	push dx
	inc cx
	and ax, ax
	jnz _4
_5:	pop dx
	add dl, '0'
	; print digit
	push ax
	push bx
	mov ah, 0x0e
	mov al, dl
	mov bh, 0
	int 0x10
	pop bx
	pop ax
	dec cx
	jnz _5
	ret

draw_snake:
	; set cursor for head
	mov bh, 0x00
	mov dx, [head]
	mov ah, 0x02
	int 0x10
	; draw head
	mov al, 2
	mov ah, 0x0e
	int 0x10
	; set cursor for body
	mov si, body
_1:	mov dx, [si]
	and dx, dx
	jz _11
	add si, 2
	mov ah, 0x02
	int 0x10
	; draw body
	mov al, 'O'
	mov ah, 0x0e
	int 0x10
	jmp _1
_11: ret

draw_food:
	; set cursor for food
	mov bh, 0x00
	mov dx, [food]
	mov ah, 0x02
	int 0x10
	; draw food
	mov al, 5
	mov bx, 0x0024
	mov cx, 1
	mov ah, 0x09
	int 0x10
	ret

move_snake:
	; find end
	mov si, body
_6:	mov ax, [si]
	and ax, ax
	jz _7
	add si, 2
	jmp _6
_7:	mov di, si
	sub di, 2
	sub si, 4

	; check eat
	mov bl, [eat]
	cmp bl, 1
	jne _8
	add si, 2
	add di, 2
	xor bl, bl
	dec byte [eat]
	inc word [score]

	; move snake
_8:	mov ax, [si]
	mov [di], ax
	sub si, 2
	sub di, 2
	cmp di, head
	jne _8
move_head:
	mov ax, [head]
	mov bl, [ort]
right:
	cmp bl, 'd'
	jne left
	inc al
	jmp end_move
left:
	cmp bl, 'a'
	jne up
	dec al
	jmp end_move
up:
	cmp bl, 'w'
	jne down
	dec ah
	jmp end_move
down:
	inc ah
end_move:
	mov [head], ax
	ret


test_collision:
	mov ax, [head]
	mov bl, [ort]
test_left:
	cmp bl, 'a'
	jne test_right
	cmp al, 0
	je game_over
	sub al, 1
	jmp test_self
test_right:
	cmp bl, 'd'
	jne test_up
	cmp al, 39
	je game_over
	add al, 1
	jmp test_self
test_up:
	cmp bl, 'w'
	jne test_down
	cmp ah, 1
	je game_over
	sub ah, 1
	jmp test_self
test_down:
	cmp ah, 24
	je game_over
	add ah, 1
test_self:
	mov si, body
_b:	mov bx, [si]
	and bx, bx
	jz _a
	cmp ax, bx
	je game_over
	add si, 2
	jmp _b
_a:	ret


game_over:
	call draw_scores
	call draw_food
	call draw_snake
	; wait for R key
	xor ah, ah
	int 0x16
	cmp al, 'r'
	jne game_over
	jmp 0xffff:0x0000

rand:
	; get rand dx = (0, bx-1)
	mov ah, 0
	int 0x1A
	mov ax, dx
	xor dx, dx
	div bx
	ret

eat_food:
	mov ax, [food]
	cmp word [head], ax
	jne _e
	inc byte [eat]
gen_food:
	; create new food
	mov bx, 40
	call rand
	mov byte [food], dl
	mov bx, 24
	call rand
	inc dx
	mov byte [food+1], dl
	; test is food on free position
	call test_food
	jc gen_food
_e:	ret

test_food:
	mov si, head
_c:
	mov ax, [si]
	and ax, ax
	jz r0
	cmp word [food], ax
	je r1
	add si, 2
	jmp _c
r1:
	stc
	ret
r0:
	clc
	ret


; variables
eat:	db 0
ort:	db 'd'
score:	dw 0
food:	dw 0x0F0F
head:	dw 0x0A0A
body:	dw 0x0A09
		dw 0x0A08
		dw 0x0000

times	510-($-$$) db 0
	dw 0xAA55

