section .bss
    num1 resb 4    ; read 3-digit number + newline
    num2 resb 4
    op   resb 2
    result resb 16 ; enough space to print result as string

section .data
    msg_number db "Enter number: ", 10
    len equ $ - msg_number

    msg_op db "Enter op (+ or -): ", 10
    len_op equ $ - msg_op

    error_msg db "Invalid operator", 10
    len_error equ $ - error_msg

section .text
global _start

_start:

    ; === prompt first number ===
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_number
    mov edx, len
    int 0x80

    ; === read num1 ===
    mov eax, 3
    mov ebx, 0
    mov ecx, num1
    mov edx, 4
    int 0x80

    ; === parse num1 to integer ===
    mov esi, num1
    call parse_number
    mov ebx, eax        ; store num1 in ebx

    ; === prompt operator ===
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_op
    mov edx, len_op
    int 0x80

    ; === read op ===
    mov eax, 3
    mov ebx, 0
    mov ecx, op
    mov edx, 2
    int 0x80

    ; === prompt second number ===
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_number
    mov edx, len
    int 0x80

    ; === read num2 ===
    mov eax, 3
    mov ebx, 0
    mov ecx, num2
    mov edx, 4
    int 0x80

    ; === parse num2 to integer ===
    mov esi, num2
    call parse_number
    mov ecx, eax        ; store num2 in ecx

    ; === determine operator ===
    mov al, [op]
    cmp al, '+'
    je do_add
    cmp al, '-'
    je do_sub

    ; === invalid operator ===
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, len_error
    int 0x80
    jmp exit

do_add:
    mov eax, ebx
    add eax, ecx
    jmp print_result

do_sub:
    mov eax, ebx
    sub eax, ecx
    jmp print_result

; -----------------------------
; Convert ASCII number string to int (eax)
; Input: ESI points to string ending in '\n'
; Output: EAX = number
parse_number:
    xor eax, eax        ; accumulator = 0
.parse_loop:
    mov bl, byte [esi]
    cmp bl, 10
    je .done
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx
    inc esi
    jmp .parse_loop
.done:
    ret

; -----------------------------
; Convert integer in EAX to ASCII string in [result] and print
print_result:
    mov edi, result + 15 ; end of buffer
    mov byte [edi], 10   ; newline
    dec edi

    xor ecx, ecx         ; digit count

.print_loop:
    xor edx, edx
    mov ebx, 10
    div ebx              ; EAX / 10, remainder in EDX
    add dl, '0'
    mov [edi], dl
    dec edi
    inc ecx
    test eax, eax
    jnz .print_loop

    inc edi              ; point to first digit

    ; print
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, ecx
    add edx, ecx
    mov edx, 16
    mov edx, result + 16
    sub edx, edi ; calculate real length to print
    int 0x80
    jmp exit

exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
