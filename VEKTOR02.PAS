Program Vektor02;
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
    YPoz   : Integer;

Procedure InitSor;
Var I: Byte;
begin
  For I := 0 to 199 Do Sor [I] := 320*I;
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
      If (Y+99 <= 199) then
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

Procedure Szinbeallit;
Var I: Byte;
begin
  For I := 0 to 255 DO SetRGB (I,I shr 2, I Shr 2, I shr 2);
end;

Procedure Beolvas;
Var T: Text;
    Sz: String;
    I : Integer;
    AktP: Integer;
    Sz2: String;
    R  : Real;
begin
  Assign (T, 'gomb.asc');
  Reset (T);
  AktP := 0;
  While not (Eof (T)) Do
  begin
    Readln (T, Sz);
    If Pos ('Vertices:',Sz) > 0 then
    begin
      Sz := Copy (Sz, Pos ('Vertices:', Sz)+10,8);
      While Sz [Length (Sz)] = #32 Do Dec (Sz [0]);
      Val (Sz, Targy.PontSzam, I);
    end;
    If (Pos ('Vertex',Sz) > 0) and (Pos ('list',Sz) = 0) then
    begin
      Sz2 := Copy (Sz, Pos ('X:', Sz)+3, 6);
      Val (Sz2, R, I);
      Targy.Pont [AktP].X := Round (R*80);
      Sz2 := Copy (Sz, Pos ('Y:', Sz)+3, 6);
      Val (Sz2, R, I);
      Targy.Pont [AktP].Y := Round (R*80);
      Sz2 := Copy (Sz, Pos ('Z:', Sz)+3, 6);
      Val (Sz2, R, I);
      Targy.Pont [AktP].Z := Round (R*80);
      Inc (AktP);
    end;
  end;
  Close (T);
end;

Procedure YTol (Var Mit, Mibe:PontObj;Ertek: Integer);
Var I: Integer;
begin
  For I := 0 to Mit.PontSzam-1 Do
  begin
    Mibe.Pont [I].X := Mit.Pont [I].X;
    Mibe.Pont [I].y := Mit.Pont [I].y+Ertek;
    Mibe.Pont [I].z := Mit.Pont [I].z;
  end;
end;

Begin
  Beolvas;
  _320x200;
  New (HKep);
  PrgVege := False;
  InitSor;
  SzinBeallit;
  YPoz:= 100;
  Repeat
    HCls;
    Inc (X,15);
    If X >= 1024 then X := X-1024;
    Inc (Y,10);
    If y >= 1024 then y := y-1024;
    If YPoz> 0 then Dec (YPoz);
    XForgat (Targy, Temp, X);
    YForgat (Temp, Temp2, Y);
    YTol (Temp2, Temp, YPoz);
    Rajz (Temp);
    HRajz;
    B.Bill;
    Case B.C1 of
      #27: PrgVege := True;
    end;
  Until PrgVege;
  Dispose (HKep);
  _80x25;
End.