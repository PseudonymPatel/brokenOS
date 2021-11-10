[ORG 0x7c00]      ; start code at 0x7c00

; move cursor to start
mov ah, 0x02
mov bh, 0
mov dx, 0x0000 ; initial cursor position
int 0x10

; load and print first message
mov bx, msgb
call biosprintstring

; load and print second message
mov bx, msga ; new string
call biosprintstring

; hang indefinitely
jmp hang

; destroys: ax, bx, cx, dx, si
biosprintstring:
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
	ret

; inf loop when done
hang:
	jmp hang

msga	db "Hello, BIOS", 0
msgb 	db "I like your big cock and balls my friend.", 0

times 510-($-$$) db 0
db 0x55
db 0xAA
