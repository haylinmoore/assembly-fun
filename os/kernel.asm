[BITS 16]  ;tell the assembler that its a 16 bit code

mov ax, 2000h
mov ds, ax

mov si, welcome
call print
mov di, userprompt
jmp showprompt

listenloop:
  mov ah, 0x00
  int 0x16
  cmp al, 8
  je backspace
  cmp al, 13
  je return
  cmp al, 0
  jne printkey

showprompt:
  call typesetup
  mov al, 62
  int 0x10
  jmp listenloop

return:
  call typesetup
  mov al, 10
  int 0x10
  mov al, 13
  int 0x10
  mov si, userprompt
  call print
  call typesetup
  mov al, 10
  int 0x10
  mov al, 13
  int 0x10
  mov di, userprompt
  call clearuserprint
  jmp showprompt

backspace:
  call typesetup
  int 0x10
  mov al, 32
  int 0x10
  mov al, 8
  int 0x10
  dec di
  mov al, 0
  stosb
  dec di
  jmp listenloop

printkey:
  call typesetup
  int 0x10     ; Call the BIOS to print letter
  stosb
  jmp listenloop

typesetup:
  mov ah, 0x0E ; Set the call type for the BIOS
  mov cx, 1    ; Times to print it
  mov bh, 0    ; Page number
  ret 

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

clearuserprint:
  mov di, userprompt
  mov ah, 32
  xor al, al
  call clearuserprintloop
  mov di, userprompt
  ret

clearuserprintloop:
  stosb
  dec ah
  cmp ah, 0
  jne clearuserprintloop
  ret

welcome db "----- Welcome to HamOS -----", 10, 13, 0, 0

userprompt times 32 db 0