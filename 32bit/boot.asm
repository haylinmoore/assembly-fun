[BITS 16]       ; We need 16-bit intructions for Real mode

[ORG 0x7C00]    ; The BIOS loads the boot sector into memory location 0x7C00
    cli                     ; Disable interrupts, we want to be alone

    xor ax, ax
    mov ds, ax              ; Set DS-register to 0 - used by lgdt

    lgdt [gdt_desc]         ; Load the GDT descriptor

    mov eax, cr0            ; Copy the contents of CR0 into EAX
    or eax, 1               ; Set bit 0
    mov cr0, eax            ; Copy the contents of EAX into CR0

    jmp 08h:clear_pipe      ; Jump to code segment, offset clear_pipe


[BITS 32]                       ; We now need 32-bit instructions
clear_pipe:
    mov ax, 10h             ; Save data segment identifyer
    mov ds, ax              ; Move a valid data segment into the data segment register
    mov ss, ax              ; Move a valid data segment into the stack segment register
    mov esp, 090000h        ; Move the stack pointer to 090000h

    push welcome
    call print
    jmp hang

printchar:
    pushad
    mov eax, [esp+ 12 + 32]
    imul eax, 80
    mov edx, [esp + 16 + 32]
    add eax, edx
    imul eax, 2
    add eax, 0x0B8000
    mov  ebx, [esp + 8 + 32]
    mov  ecx, [esp + 4 + 32]
    mov byte [ds:eax], bl
    mov byte [ds:eax+1], cl
    popad
    ret 20

print:
    pushad
    mov  si, [esp + 32 + 4]
    mov ebx, 0
    mov ecx, 0
    jmp print_loop
  
print_loop:
    lodsb
    cmp al, 0
    je print_exit
    cmp al, 10
    je print_newline
    push ebx   ; set x pos
    push ecx    ; set y pos
    push eax   ; set character
    push 0x1B ; set color
    call printchar
    inc ebx
    cmp ebx, 80
    je print_newline
    jmp print_loop

print_newline:
    inc ecx
    xor ebx, ebx
    jmp print_loop

print_exit:
    popad
    ret

welcome db "----- Welcome to HamOS -----", 10, "I hope you enjoy your stay", 10, ">", 0
hang:
    jmp hang                ; Loop, self-jump

gdt:                    ; Address for the GDT
gdt_null:               ; Null Segment
    dd 0
    dd 0
gdt_code:               ; Code segment, read/execute, nonconforming
    dw 0FFFFh
    dw 0
    db 0
    db 10011010b
    db 11001111b
    db 0
gdt_data:               ; Data segment, read/write, expand down
    dw 0FFFFh
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0
gdt_end:                ; Used to calculate the size of the GDT
gdt_desc:                       ; The GDT descriptor
    dw gdt_end - gdt - 1    ; Limit (size)
    dd gdt                  ; Address of the GDT

times 510-($-$$) db 0           ; Fill up the file with zeros
    dw 0AA55h                ; Boot sector identifyer