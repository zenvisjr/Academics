; custom_allocator.asm

section .data
    memory: resb 1048576  ; 1 MB of memory
    head: dq 0            ; Head of the memory block list

section .text
    global init_allocator
    global my_malloc
    global my_calloc
    global my_realloc
    global my_free

; Structure of MemoryBlock
; 0  - size (8 bytes)
; 8  - is_free (4 bytes)
; 12 - padding (4 bytes)
; 16 - next (8 bytes)
; Total size: 24 bytes

init_allocator:
    mov qword [head], memory
    mov qword [memory], 1048552  ; 1048576 - 24 (size of MemoryBlock)
    mov dword [memory + 8], 1    ; is_free = 1
    mov qword [memory + 16], 0   ; next = NULL
    ret

my_malloc:
    push rbp
    mov rbp, rsp
    push rbx
    
    ; Check if size is 0
    test rdi, rdi
    jz .return_null
    
    ; Find a free block
    mov rbx, [head]
.find_free_block:
    test rbx, rbx
    jz .return_null
    
    cmp dword [rbx + 8], 1  ; Check if block is free
    jne .next_block
    
    cmp qword [rbx], rdi    ; Check if block size is sufficient
    jge .found_block
    
.next_block:
    mov rbx, [rbx + 16]
    jmp .find_free_block
    
.found_block:
    ; Mark block as allocated
    mov dword [rbx + 8], 0
    
    ; Split block if necessary
    mov rax, [rbx]
    sub rax, rdi
    cmp rax, 25  ; 24 (size of MemoryBlock) + 1
    jl .return_block
    
    ; Perform split
    mov rcx, rbx
    add rcx, 24   ; Size of MemoryBlock
    add rcx, rdi
    mov [rcx], rax
    sub qword [rcx], 24
    mov dword [rcx + 8], 1  ; Mark new block as free
    mov rdx, [rbx + 16]
    mov [rcx + 16], rdx     ; Set next of new block
    mov [rbx + 16], rcx     ; Set next of current block
    mov [rbx], rdi          ; Update size of current block
    
.return_block:
    lea rax, [rbx + 24]
    jmp .end
    
.return_null:
    xor rax, rax
    
.end:
    pop rbx
    pop rbp
    ret

my_calloc:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    
    mov rbx, rdi  ; num
    mov r12, rsi  ; size
    
    ; Calculate total size
    mov rax, rbx
    mul r12
    mov r13, rax  ; Save total size in r13
    mov rdi, rax
    
    ; Call my_malloc
    call my_malloc
    test rax, rax
    jz .end
    
    ; Zero out the allocated memory
    mov rdi, rax
    mov rcx, r13
    xor al, al
    rep stosb
    
    mov rax, rdi  ; Restore the original pointer
    sub rax, r13  ; Adjust back to the start of the allocated memory
    
.end:
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

my_realloc:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    
    mov rbx, rdi  ; ptr
    mov r12, rsi  ; new_size
    
    ; If ptr is NULL, call my_malloc
    test rbx, rbx
    jz .call_malloc
    
    ; If new_size is 0, call my_free
    test r12, r12
    jz .call_free
    
    ; Get the MemoryBlock
    sub rbx, 24
    
    ; If new size is smaller, split the block
    mov r13, [rbx]  ; Current size
    cmp r13, r12
    jl .expand
    
    ; Shrink the block
    mov [rbx], r12
    add rbx, 24
    mov rax, rbx
    jmp .end
    
.expand:
    ; Allocate new block
    mov rdi, r12
    call my_malloc
    test rax, rax
    jz .end
    
    ; Copy data
    mov rdi, rax
    lea rsi, [rbx + 24]
    mov rcx, r13
    rep movsb
    
    ; Free old block
    lea rdi, [rbx + 24]
    call my_free
    
    jmp .end
    
.call_malloc:
    mov rdi, r12
    call my_malloc
    jmp .end
    
.call_free:
    call my_free
    xor rax, rax
    
.end:
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

my_free:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    
    test rdi, rdi
    jz .end
    
    ; Get the MemoryBlock
    sub rdi, 24
    mov rbx, rdi
    
    ; Mark as free
    mov dword [rbx + 8], 1
    
    ; Merge with next block if it's free
    mov r12, [rbx + 16]
    test r12, r12
    jz .check_prev
    
    cmp dword [r12 + 8], 1
    jne .check_prev
    
    ; Merge
    mov rax, [r12]
    add [rbx], rax
    add qword [rbx], 24
    mov rax, [r12 + 16]
    mov [rbx + 16], rax
    
.check_prev:
    ; Merge with previous block if it's free
    mov rdi, [head]
    
.find_prev:
    cmp rdi, rbx
    je .end
    
    mov r12, [rdi + 16]
    test r12, r12
    jz .end
    
    cmp r12, rbx
    je .found_prev
    
    mov rdi, r12
    jmp .find_prev
    
.found_prev:
    cmp dword [rdi + 8], 1
    jne .end
    
    ; Merge
    mov rax, [rbx]
    add [rdi], rax
    add qword [rdi], 24
    mov rax, [rbx + 16]
    mov [rdi + 16], rax
    
.end:
    pop r12
    pop rbx
    pop rbp
    ret