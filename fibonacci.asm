%define maxChars 3

section .data

    msge: db "Execução encerrada", 10
    msgeL: equ $ - msge    

    erro: db "Entrada Inválida!", 10
    erroL: equ $ - erro  
    
    msg: db "Fibonacci requerido (até xx): "
    msgL: equ $ - msg
   
    nomearquivo: db "fib("
    nomearquivoL: equ $ - nomearquivo

    restoStr: db ").bin", 0
section .bss
    
    n: resb maxChars
    nL: resd 1

    fileHandle: resd 1

    valor: resq 1

    appendNome: resd 1 

section .text
    global _start

_start:
    ;syscall p/ mensagem "Fibonacci requerido"
    mov rax, 1 ;WRITE
    mov rdi, 1
    lea rsi, [msg]
    mov edx, msgL
    syscall

lendo:
    mov dword [nL], maxChars 
    
    ;syscall p/ ler n-éssimo numero
    mov rax, 0 ;READ
    mov rdi, 1
    lea rsi, [n]
    mov edx, nL
    syscall

    mov [nL], eax

    mov r10d, [nL]

    cmp r10d, 0x1
    je falha
    cmp r10d, 0x3 
    jg falha

transformacao:
    mov r12b, [n]
    sub r12b, 0x30
    
    ;compara se proximo byte é um "Enter"
    cmp byte [n+1], 10
    je resultado
        
    ;caso não seja um "Enter"
    mov dl, byte [n+1]
    sub dl, 0x30
        
    ;transforma de ascii para decimal
    xor ax, ax
    xor bx, bx
        
    mov al, r12b
    mov bl, 10

    imul ax, bx

    mov r12b, al

    add r12b, dl

resultado:

    iniciofor:
        xor r9, r9 ;contador
        xor r13, r13 ;fib0
        mov r14, 0x0001 ;fib1

        prebloco:
            cmp r9b, r12b ;compara contador com valor inserido
            je saidafor 

        blocofor:
            mov r15b, r13b ;aux recebe fib0
            add r15b, r14b ;aux recebe aux+fib1
            mov r13b, r14b ;fib0 recebe fib1
            mov r14b, r15b ;fib1 recebe aux
            inc r9         ;incrementa r9
            jmp prebloco

    saidafor:

nomeandoarquivo:
    mov r11, 4
    mov r14, qword [n]
    mov r15, qword [restoStr]
    mov [nomearquivo+r11], r14

nomeandoarquivo2:
    add r11, [nL]
    dec r11
    mov [nomearquivo+r11], r15


abrearquivo:
    mov rax, 2             ; open file
    lea rdi, [nomearquivo] ; *pathname
    mov esi, 2102o         ; flags
    mov edx, 644o          ; mode
    syscall

    mov [fileHandle], eax

escrita:
    mov qword[valor], r13

    mov rax, 1
    mov rdi, [fileHandle]
    lea rsi, [valor]
    mov edx, 8
    syscall

fechaarquivo:
    mov rax, 3
    mov edi, [fileHandle]
    syscall
    jmp fim

falha:
    mov rax, 1
    mov rdi, 1
    lea rsi, [erro]
    mov edx, erroL
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, [msge]
    mov edx, msgeL
    syscall

fim:
    mov rax, 60
    mov rdi, 0
    syscall