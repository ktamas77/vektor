Const EGAPal: Array [0..15] of Byte = (0,1,2,3,4,5,20,7,56,57,58,59,60,61,62,63);

Type RGBColTip = Record
       R, G, B: Byte;
     end;

Type RGBMap = Array [0..255] of RGBColTip;

Procedure SetRGB (C, R, G, B: Byte);Assembler;
asm
  mov dx, 03c8h
  mov al, c;out dx, al
  inc dx
  mov al, r;out dx, al
  mov al, g;out dx, al
  mov al, b;out dx, al
end;

Procedure GetRGB (C: Byte; Var Col: RGBColTip);Assembler;
asm
  cld
  les di, col
  mov dx, 03c7h {olvasas}
  mov al, c;out dx, al
  add dx, 2
  in al, dx;stosb
  in al, dx;stosb
  in al, dx;stosb
end;

Procedure RW;Assembler;
asm
  mov dx, 03dah
  @j1: in al, dx;test al, 8;jz @j1
  @j2: in al, dx;test al, 8;jnz @j2
end;

Procedure HRW;Assembler;
asm
  mov dx, 03dah
  @j1: in al, dx;test al, 1;jz @j1
  @j2: in al, dx;test al, 1;jnz @j2
end;

Procedure GetRGBPal (Var R: RGBMap);Assembler;
asm
  cld
  xor cx, cx
  les di, r
  @ciklus:
    mov dx, 03c7h {olvasas}
    mov al, cl;out dx, al
    add dx, 2
    in al, dx;stosb
    in al, dx;stosb
    in al, dx;stosb

    inc cx
    cmp cx, 256
    jne @ciklus
end;

Procedure SetRGBPal (Var R: RGBMap);Assembler;
asm
  cld
  push ds
  xor cx, cx
  lds si, r
  @ciklus:
    mov dx, 03c8h {iras}
    mov al, cl;out dx, al
    inc dx
    lodsb;out dx, al
    lodsb;out dx, al
    lodsb;out dx, al

    inc cx
    cmp cx, 256
    jne @ciklus
  pop ds
end;

Procedure PalCorrect (Var Mit: RGBMap);
Var I: Byte;
begin
  For I := 0 to 255 Do
    With Mit [I] Do
    begin
      R := R shr 2;
      G := G shr 2;
      B := B shr 2;
    end;
end;

Procedure Contrast (Var Mit: RGBMap;C, Max: Word);
Var I: Byte;
begin
  For I := 0 to 255 DO
  With Mit [I] Do
  begin
    R := (LongInt (R)*C) div Max;
    G := (LongInt (G)*C) div Max;
    B := (LongInt (B)*C) div Max;
  end;
end;

Procedure Flash (B: Boolean);Assembler;
asm
  mov ax, 01003h
  mov bl, b
  and bl, 1
  int 10h
end;

Procedure SetCursorSize (Top, Bottom: Byte);Assembler;
asm
  mov ah, 1
  mov ch, top
  mov cl, bottom
  and cx, 01f1fh
  int 10h
end;

Procedure CursorOff;Assembler;
asm
  mov ah, 1
  mov ch, 127
  int 10h
end;

Procedure CursorOn;
begin
  SetCursorSize (9, 10);
end;

Procedure _320x200;Assembler;
asm
  mov ax, 13h
  int 10h
end;

Procedure _80x25;Assembler;
asm
  mov ax, 3h
  int 10h
end;

Procedure _80x50;Assembler;
asm
  mov  ax,0003h
  int  10h
  mov  ax,1112h
  xor  dx,dx
  mov  bx,0800h
  mov  cx,256
  int  10h
end;

Procedure _80x28;Assembler;
asm
  mov  ax,0003h
  int  10h
  mov  ax,1111h
  xor  dx,dx
  mov  bx,0800h
  mov  cx,256
  int  10h
end;

Procedure Pix1_1;Assembler;
asm
  mov dx, 03c2h
  mov ax, 0e2f3h
  out dx, ax
end;

Procedure Box8;Assembler;
asm
  mov  dx,$3cc
  in   al,dx
  and  al,$f3
  mov  dx,$3c2
  out  dx,al
  mov  dx,$3c4
{$IFDEF SeqRESET}
  mov  ax,0100h
  out  dx,ax
{$ENDIF}
  mov  al,1
  out  dx,al
  inc  dx
  in   al,dx
  or   al,1
  out  dx,al
{$IFDEF SeqRESET}
  dec  dx
  mov  ax,0300h
  out  dx,ax
{$ENDIF}
  mov  dx,$3da
  in   al,dx
  mov  dx,$3c0
  mov  al,$13
  out  dx,al
  xor  al,al
  out  dx,al
  mov  al,$20
  out  dx,al
end;

Procedure Box9;Assembler;
asm
  mov  dx,$3cc
  in   al,dx
  or   al,4
  mov  dx,$3c2
  out  dx,al
  mov  dx,$3c4
{$IFDEF SeqRESET}
  mov  ax,0100h
  out  dx,ax
{$ENDIF}
  mov  al,1
  out  dx,al
  inc  dx
  in   al,dx
  and  al,$fe
  out  dx,al
{$IFDEF SeqRESET}
  dec  dx
  mov  ax,0300h
  out  dx,ax
{$ENDIF}
  mov  dx,$3da
  in   al,dx
  mov  dx,$3c0
  mov  al,$13
  out  dx,al
  mov  al,8
  out  dx,al
  mov  al,$20
  out  dx,al
end;
