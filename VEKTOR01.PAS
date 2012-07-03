Program Vektor01;
{$G+}
{$A+}
{$R-}
{$N+,E-}

Uses Crt;

{$I VGA.INC}
{$I BILL.INC}

Type KepTip = Array [0..63999] of Byte;

Type Point3D = Record
       X, Y, Z: Integer;
       Szin   : Byte;
     end;

Type PontObj = Record
       PontSzam: Word;
       Pont    : Array [0..1999] of Point3D;
     end;

Var PrgVege: Boolean;
    B      : BillTip;
    Sor    : Array [0..199] of Word;
    Targy  : PontObj;
    Temp   : PontObj;
    Temp2  : PontObj;
    VKep   : KepTip absolute $A000:00;
    HKep   : ^KepTip;
    X      : Integer;
    Y      : Integer;

Procedure InitSor;
Var I: Byte;
begin
  For I := 0 to 199 Do Sor [I] := 320*I;
end;

Procedure General;
Var I: Integer;
    J: Integer;
begin
  Targy.PontSzam := 2000;
  For J := 0 to 9 Do
  begin
    For I := 0 to 199 Do
      With Targy.Pont [I+J*200] Do
      begin
        X := Trunc (Cos (I/(50/Pi))*50);
        Y := Trunc (Cos (I/(100/Pi))*50);
        Z := Trunc (Sin (I/(100/Pi))*50);
      end;
  end;
end;

Procedure HCLS;Assembler;
asm
  les di, hkep
  mov cx, 64000/2
  xor ax, ax
  rep stosw;
end;

Procedure HRajz;Assembler;
asm
  mov bx, ds
  mov ax, 0a000h
  mov es, ax
  xor di, di
  lds si, hkep
  mov cx, 64000/2
  rep movsw
  mov ds, bx
end;

Procedure Rajz (Var Mit: PontObj);
Var I: Integer;
begin
  For I := 0 to Mit.PontSzam-1 Do
    With Mit.Pont [I] Do
    begin
      HKep^[159+X+Sor [99+Y]] := Z+80;
    end;
end;

Procedure xForgat (Var Mibol, Mibe: PontoBJ;Fok: Integer);
Var I: Integer;
begin
  Mibe.PontSzam := Mibol.PontSzam;
  For I := 0 to Mibol.PontSzam-1 Do
  begin
    Mibe.Pont [I].Szin := Mibol.Pont [I].Szin;
    Mibe.Pont [I].X := Mibol.Pont [I].X;
    Mibe.Pont [I].Y := Trunc (((Cos (Fok/(512/Pi))*Mibol.Pont [I].y))+
                              ((Sin (Fok/(512/Pi))*Mibol.Pont [I].z)));
    Mibe.Pont [I].Z := Trunc (((Sin (Fok/(512/Pi))*Mibol.Pont [I].Y))-
                              ((Cos (Fok/(512/Pi))*Mibol.Pont [I].z)));
  end;
end;

Procedure yForgat (Var Mibol, Mibe: PontoBJ;Fok: Integer);
Var I: Integer;
begin
  Mibe.PontSzam := Mibol.PontSzam;
  For I := 0 to Mibol.PontSzam-1 Do
  begin
    Mibe.Pont [I].Szin := Mibol.Pont [I].Szin;
    Mibe.Pont [I].X := Trunc (((Cos (Fok/(512/Pi))*Mibol.Pont [I].x))+
                              ((Sin (Fok/(512/Pi))*Mibol.Pont [I].z)));
    Mibe.Pont [I].Y := Mibol.Pont [I].Y;
    Mibe.Pont [I].Z := Trunc (((Sin (Fok/(512/Pi))*Mibol.Pont [I].X))-
                              ((Cos (Fok/(512/Pi))*Mibol.Pont [I].z)));
  end;
end;

(*Procedure XForg (Fok: Integer);
{T1--> AktT}
Var I: Word;
begin
  With T1 Do
    For I := 1 to PontSzam Do
    With Pont [I] Do
    begin
      AktTargy.Pont [I].x := t1.Pont [I].x;
      AktTargy.Pont [I].y := LongDiv (LongMul (Ca [Fok],Pont [I].y)+
                              LongMul (Sa [Fok],Pont [I].z), Szorzo);
      AktTargy.Pont [I].z := LongDiv (LongMul (Sa [Fok],Pont [I].y)-
                              LongMul (Ca [Fok],Pont [I].z), Szorzo);
    end;
end;*)


Procedure Progi;
Var X, y: Integer;
    I   : Integer;
begin
  I := 0;
  repeat
    HCls;
    X := Trunc (Sin (I/(180/Pi))*100);
    Y := Trunc (Cos (I/(180/Pi))*50);
    HKep^[159+X+Sor [99+Y]] := 15;
    HRajz;
    Inc (I);
    If I >= 360 then I := 0;
  Until KeyPressed;
  While KeyPressed Do Readkey;
end;

Procedure Szinbeallit;
Var I: Byte;
begin
  For I := 0 to 255 DO SetRGB (I,I shr 2, I Shr 2, I shr 2);
end;

Begin
  _320x200;
  New (HKep);
  PrgVege := False;
  InitSor;
  General;
  SzinBeallit;
  Repeat
    HCls;
    Inc (X,15);
    If X >= 1024 then X := X-1024;
    Inc (Y,10);
    If y >= 1024 then y := y-1024;
    XForgat (Targy, Temp, X);
    YForgat (Temp, Temp2, Y);
    Rajz (Temp2);
    HRajz;
    B.Bill;
    Case B.C1 of
      #27: PrgVege := True;
    end;
  Until PrgVege;
  Dispose (HKep);
  _80x25;
End.