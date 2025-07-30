section .bss
    num1 resb 3    ; read digit + newline safely
    num2 resb 3
    op   resb 2
    result resb 3  ; digit + newline

section .data
	msg_number dd "Enter number : ",10
	len equ $ - msg_number

	msg_op dd "Enter op (+ or -) : ",10
	len_op equ $ - msg_op

	error_msg dd "Invalid operator",10
	len_error equ $ - error_msg
section .text
global _start

_start:
	; === prompt first number ===
	MOV eax, 4
	MOV ebx, 1
	MOV ecx, msg_number 
	MOV edx, len
	INT 0x80

	; === read first number ===
	MOV eax, 3      ; syscall: read
    	MOV ebx, 0      ; stdin (keyboard)
    	MOV ecx, num1   ; pointer to buffer
    	MOV edx, 3      ; max bytes to read
    	INT 0x80

	; === prompt op ===
        MOV eax, 4
        MOV ebx, 1
        MOV ecx, msg_op   
       	MOV edx, len_op
        INT 0x80	

	; === read op ===
	MOV eax, 3      ; syscall: read
	MOV ebx, 0      ; stdin (keyboard)
	MOV ecx, op   ; pointer to buffer
	MOV edx, 2      ; max bytes to read
	INT 0x80

	; === prompt second number ===
	MOV eax, 4
	MOV ebx, 1
	MOV ecx, msg_number
	MOV edx, len
	INT 0x80

	; === read second number ===
	MOV eax, 3
	MOV ebx, 0
	MOV ecx, num2
	MOV edx, 3
	INT 0x80

	; === convert to inetgers ===
	MOV al, [num1]
	SUB al, '0'
	MOV bl, al         ; bl = num1

	MOV al, [num2]
	SUB al, '0'
	MOV cl, al

	; === check operator ===
	MOV al, [op]
	CMP al, '+'
	JE do_add

	CMP al, '-'
	JE do_sub

	JMP invalid_op

do_add:
	MOV al, bl
	ADD al, cl
	JMP store

do_sub:
	MOV al, bl
	SUB al, cl
	JMP store

invalid_op:
	MOV eax, 4
	MOV ebx, 1
	MOV ecx, error_msg
	MOV edx, len_error
	INT 0x80 
store:
    	ADD al, '0'            ; convert result number to ASCII
    	MOV [result], al       ; store result character
    	MOV byte [result+2], 10 ; store newline character

    ; print result (2 bytes: digit + newline)
    	MOV eax, 4
    	MOV ebx, 1
    	MOV ecx, result
    	MOV edx, 3
    	INT 0x80

	; === exit safely ===
	MOV eax,1
	XOR ebx,ebx
	INT 0x80

