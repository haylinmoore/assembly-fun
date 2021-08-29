[BITS 16]  ;tell the assembler that its a 16 bit code
[ORG 0x7C00];Origin, tell the assembler that where the code will
            ;be in memory after it is been loaded

; Clear screen
call clearscreen
; Player starts at 3x3
mov dh, 3
mov dl, 3

jmp gameloop

gameloop:
  call drawplayer
  call controlplayer
  jmp gameloop

hlt

clearscreen:
  mov ah, 0x02 
  mov bh, 0
  mov dh, 0
  mov dl, 0
  int 0x10
  mov ah, 0x0a
  mov al, 32
  mov cx, 1000
  int 0x10
  ret

moveright:
  inc dl
  jmp checkmove

moveleft:
  dec dl
  jmp checkmove

movedown:
  inc dh
  jmp checkmove

moveup:
  dec dh
  jmp checkmove

losegame:
  call clearscreen
  mov dh, 3
  mov dl, 3
  ret

checkmove:
  call updatemouse
  mov ah, 0x08
  int 0x10
  cmp al, 0x01
  je losegame
  jmp drawplayer  

controlplayer:
  mov ah, 0x00 
  int 0x16
  cmp al, "d"
  je moveright
  cmp al, "a"
  je moveleft
  cmp al, "w"
  je moveup
  cmp al, "s"
  je movedown

eraseplayer:
  ret
  mov ah, 0x02 
  int 0x10
  mov ah, 0x0a
  mov al, " "
  mov cx, 1
  int 0x10
  ret

updatemouse:
  mov ah, 0x02 
  int 0x10
  ret

drawplayer:
  call updatemouse 
  mov ah, 0x0a
  mov al, 0x01
  mov cx, 1
  int 0x10
  ret
TIMES 510 - ($ - $$) db 0    ;fill the rest of sector with 0
DW 0xAA55          ; add boot signature at the end of bootloader
