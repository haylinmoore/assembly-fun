[BITS 16]  ;tell the assembler that its a 16 bit code
[ORG 0x7C00];Origin, tell the assembler that where the code will
            ;be in memory after it is been loaded

mov si, bios
call print
mov si, kernel
call print
mov ax, 2000h
mov es, ax
xor bx, bx
mov ah, 2
mov al, 1
mov cl, 2
mov ch, 0
mov dh, 0
int 13h

jmp 2000h:0

print: 
  mov ah, 0eh
  mov cx, 1
  mov bh, 0
  jmp print_loop
  
print_loop:
  lodsb
  cmp al, 0
  je print_exit
  int 10h
  jmp print_loop

print_exit:
  ret

bios   db "BIOS loaded...", 10, 13, 0, 0
kernel db "Loading kernel...", 10, 13, 0, 0

TIMES 510 - ($ - $$) db 0    ;fill the rest of sector with 0
DW 0xAA55          ; add boot signature at the end of bootloader