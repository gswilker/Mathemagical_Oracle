section .data
    msg_start1  db "Pense em um numero de 0 a 1.000...", 10, 0
    msg_start2  db "Quando tiver pensado, aperte ENTER para eu tentar advinhar!", 10, 0
    msg_prompt1 db "O numero que voce pensou eh maior(+), igual(=) ou menor (-) que ", 0
    msg_prompt2 db "?", 10, 0
    msg_win1    db "Ja descobri! O numero eh ", 0
    msg_win2    db "!", 10, 0
    msg_count1  db "Precisei de apenas ", 0
    msg_count2  db " tentativa(s) para acertar!", 10, "Bom jogo!", 10, 0
    msg_err     db 10, "A emocao eh tanta que voce digitou errado! Vamos voltar:", 10, 0

section .bss
    input_buf   resb 16
    num_buf     resb 16

section .text
    global _start

_start:
    mov r12d, 0                 ; int l = 0;
    mov r13d, 1000              ; int h = 1000;
    mov r15d, 0                 ; int tentativas = 0;

    mov rsi, msg_start1
    call print_str

    mov rsi, msg_start2
    call print_str

    call read_input             ; getchar();

game_loop:
    cmp r12d, r13d              ; while (l <= h)
    jg exit_game

    ; int m = l + (h - l) / 2;
    mov eax, r13d
    sub eax, r12d
    shr eax, 1
    add eax, r12d
    mov r14d, eax               ; r14d = m

    inc r15d                    ; Incrementa a contagem de perguntas válidas

    ; printf("O numero que voce pensou ... %d?\n", m);
    mov rsi, msg_prompt1
    call print_str

    mov eax, r14d
    call print_num

    mov rsi, msg_prompt2
    call print_str

    ; scanf(" %c", &resp);
    call read_input
    mov al, byte [input_buf]

    cmp al, '-'
    je step_minus

    cmp al, '+'
    je step_plus

    cmp al, '='
    je step_equal

    ; else: digitação inválida
    dec r15d                    ; Desfaz o incremento da tentativa
    mov rsi, msg_err
    call print_str
    jmp game_loop

step_minus:
    mov r13d, r14d
    dec r13d                    ; h = m - 1;
    jmp game_loop

step_plus:
    mov r12d, r14d
    inc r12d                    ; l = m + 1;
    jmp game_loop

step_equal:
    mov rsi, msg_win1
    call print_str

    mov eax, r14d
    call print_num

    mov rsi, msg_win2
    call print_str

    ; Exibe a quantidade final de tentativas
    mov rsi, msg_count1
    call print_str

    mov eax, r15d
    call print_num

    mov rsi, msg_count2
    call print_str

    jmp exit_game

exit_game:
    mov rax, 60                 ; sys_exit
    xor rdi, rdi                ; exit code 0
    syscall

; -------------------------------------------------------------------
; FUNÇÕES AUXILIARES DE ENTRADA/SAÍDA
; -------------------------------------------------------------------

print_str:
    push rax
    push rdi
    push rdx
    push rsi
    mov rdx, 0
.len:
    cmp byte [rsi + rdx], 0
    je .write
    inc rdx
    jmp .len
.write:
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    syscall
    pop rsi
    pop rdx
    pop rdi
    pop rax
    ret

print_num:
    push rax
    push rbx
    push rdx
    push rsi
    push rdi
    mov ebx, 10
    mov rdi, num_buf + 15
    mov byte [rdi], 0
.convert:
    xor edx, edx
    div ebx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test eax, eax
    jnz .convert
    mov rsi, rdi
    call print_str
    pop rdi
    pop rsi
    pop rdx
    pop rbx
    pop rax
    ret

read_input:
    push rax
    push rdi
    push rsi
    push rdx
    mov rax, 0                  ; sys_read
    mov rdi, 0                  ; stdin
    mov rsi, input_buf
    mov rdx, 16
    syscall
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret