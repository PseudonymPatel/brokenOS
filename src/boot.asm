[ORG 0x7c00]      ; start code at 0x7c00

; move cursor to start
mov ah, 0x02
mov bh, 0
mov dx, 0x0000 ; initial cursor position
int 0x10

; load and print first message
mov bx, longmessage
call biosprintstring

; load and print second message
mov bx, msga ; new string
call biosprintstring

; what's in bx??????
mov bx, 0xaaaa
call printregister

; hang indefinitely
jmp hang

; FUNCTION biosprintstring
;	prints string using bios teletype function, beginning at start of line.
; 	IN bx = register containing address to string
biosprintstring:
	;push registers used onto stack
	push si
	push ax
	push bx
	push cx
	push dx

	mov si, bx ; load si with the string ptr

	; get cursor position
	mov ah, 0x03
	mov bh, 0
	int 0x10

	; move cursor to line start
	mov ah, 0x02
	mov bh, 0
	mov dl, 0 ; column, dh = row, set from getting cursor position`
	int 0x10
bpstringmain:
	mov al, [si] ; load next character
	cmp al, 0 ; if the character is null, jump to hang
	je endpstring
	; call biosprintchar ; print the char in al
	mov ah, 0x0E
	mov bh, 0
	mov bl, 0x04
	int 0x10

	mov ah, 0x02
	mov bh, 0
	inc dl
	;int 0x10

	inc si
	jmp bpstringmain

endpstring:
	; new line then return
	; get cursor position to move it to next row
	mov ah, 0x03
	mov bh, 0
	int 0x10

	mov ah, 0x02
	mov bh, 0
	inc dh ; next line
	mov dl, 0 ; cursor to start
	int 0x10

	; pop registers used
	pop dx
	pop cx
	pop bx
	pop ax
	pop si
	ret
; END FUNCTION biosprintstring

; FUNCTION printregister
;	prints the value held by a register
; 	bx = value to print
;	DESTORYS - a bunch, TODO!!
printregister:
	push ax
	push bx

	; need to convert hex to ascii
	; for each bit of bx, add 0x30 if <=0x9 or 0x37 if >0x9
	xor ax, ax
	mov al, bl ; start with bl and work up to top of ah
	and al, 0x0f ; lowest bit of bl only
	add al, 0x30
	cmp al, 0x09
	jle _prg1
	add al, 0x07
_prg1:
	mov [registervalue16bit], byte al

	; high byte of bl
	xor ax, ax
	mov al, bl
	and al, 0xf0
	shr al, 4 ; shift into lower part of al
	add al, 0x30
	cmp al, 0x09
	jle _prg2
	add al, 0x07
_prg2:
	mov [registervalue16bit-0x02], byte al

	mov bx, registervalue16bit
	call biosprintstring
	pop bx
	pop ax
	ret
; ENG FUNCTION printregister

; inf loop when done
hang:
	jmp hang

msga		db "Hello, BIOS", 0
longmessage	db "I like your big cock and balls my friend.", 0
registervalue16bit db 0x0000

times 510-($-$$) db 0
db 0x55
db 0xAA
