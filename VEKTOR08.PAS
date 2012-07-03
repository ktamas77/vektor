Program Vektor08;
{$G+}
{$A+}
{$R-}
{$N+,E-}

Uses Crt;

{$I VGA.INC}
{$I BILL.INC}
{$I FTRI.INC}
{$I LONG.INC}

Const SinMax = 1024;
      Szorzo = 32000;

Type KepTip = Array [0..63999] of Byte;

Type Point3D = Record
       X, Y, Z: Integer;
       Szin   : Byte;
     end;

Type LapTip = Record
       A: Integer;
       B: Integer;
       C: Integer;
     end;

Type PontObj = Record
       PontSzam: Word;
       LapSzam : Word;
       Pont    : Array [0..1999] of Point3D;
       Lap     : Array [0..3999] of LapTip;
     end;

Var PrgVege : Boolean;
    B       : BillTip;
    Sor     : Array [0..199] of Word;
    Targy   : ^PontObj;
    Temp    : ^PontObj;
    Temp2   : ^PontObj;
    VKep    : KepTip absolute $A000:00;
    HKep    : ^KepTip;
    X       : Integer;
    Y       : Integer;
    Z       : Integer;
    YPoz    : Integer;
    SinT    : Array [0..SinMax-1] of Integer;
    CosT    : Array [0..SinMax-1] of Integer;
    SikTombX: Array [0..3999] of Integer;
    SikTombY: Array [0..3999] of Integer;
    BurkErt : Array [0..3999] of Integer;
    BurkSor : Array [0..3999] of Integer;

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
  rep stosw
end;

Procedure HRajz;Assembler;
asm
  mov bx, ds
  mov ax, 0a000h
  mov es, ax
  xor di, di
  lds si, hkep
  mov cx, 64000/4
  db 066h; rep movsw
  mov ds, bx
end;

procedure Swap (i, j : word);                  { k‚t elem kicser‚l‚se      }
var dummy : Integer;
begin
  dummy := BurkSor [i]; BurkSor [i] := BurkSor [j]; BurkSor [j] := dummy;
  dummy := BurkErt [i]; BurkErt [i] := BurkErt [j]; BurkErt [j] := dummy;
end; { Swap }

procedure QuickSort (left, right : word);
{Szok sos quicksort rendez‚s...}
Var up, down, compare : Integer;
begin
  asm
    mov ax, left {up := left;}
    mov up, ax
    mov ax, right {down := right;}
    mov down, ax
  end;
  compare := BurkErt [(left + right) shr 1];
  repeat
    while BurkErt [up] < compare do asm inc up end;
    while compare < BurkErt [down] do asm dec down end;
    if up <= down then
      begin Swap (up, down);asm inc up;dec down end;end;
  until up > down;
 if left < down then QuickSort (left, down);
 if up < right then QuickSort (up, right);
end; { QuickSort }

Procedure Rajz (Var Mit: PontObj;Var Eredeti: PontObj);
Var I : Integer;
    AL: Integer;
    BL: Integer;
    CL: Integer;
begin
  {2D konvertalas}
  For I := 0 to Eredeti.PontSzam-1 Do
  begin
    SikTombX [I] := 199+Eredeti.Pont [I].X;
    SikTombY [I] := 199+Eredeti.Pont [I].Y;
  end;

  {Lapok ertekenek inicializalasa}
  For I := 0 to Eredeti.LapSzam-1 Do
  begin
    BurkSor [I] := I;
    BurkErt [I] := (Mit.Pont [Eredeti.Lap [I].A].Z)+
                   (Mit.Pont [Eredeti.Lap [I].B].Z)+
                   (Mit.Pont [Eredeti.Lap [I].C].Z);
  end;

  {Sorbarendezes}
  QuickSort (0, Eredeti.LapSzam-1);

  With Mit Do
  begin
    For I := 0 to Eredeti.LapSzam-1 Do
      With Eredeti.Lap [BurkSor [I]] Do
        FTri (HKep,   SikTombX [a], SikTomby [a],
                      SikTombX [b], SikTomby [b],
                      SikTombX [c], SikTomby [c], Byte (I));
  end;
end;

Procedure xForgat (Var Mibol, Mibe, Eredeti: PontoBJ;Fok: Integer);
Var I   : Integer;
    My  : Integer;
    Mz  : Integer;
    SF  : Integer;
    CF  : Integer;
begin
  For I := 0 to Eredeti.PontSzam-1 Do
  begin
    My := Mibol.Pont [I].y;
    Mz := Mibol.Pont [I].z;
    SF := SinT [Fok];
    CF := CosT [Fok];
    Mibe.Pont [I].X := Mibol.Pont [I].X;
    Mibe.Pont [I].Y := LongDiv (LongMul (CF, My)+LongMul (SF,Mz), Szorzo);
    Mibe.Pont [I].Z := LongDiv (LongMul (SF, My)-LongMul (CF,Mz), Szorzo);
  end;
end;

Procedure yForgat (Var Mibol, Mibe, Eredeti: PontoBJ;Fok: Integer);
Var I    : Integer;
    Mx   : Integer;
    Mz   : Integer;
    SF   : Integer;
    CF   : Integer;
begin
  For I := 0 to Eredeti.PontSzam-1 Do
  begin
    Mx := Mibol.Pont [I].x;
    Mz := Mibol.Pont [I].z;
    SF := SinT [Fok];
    CF := CosT [Fok];
    Mibe.Pont [I].X := LongDiv (LongMul (CF, Mx)+LongMul (SF,Mz), Szorzo);
    Mibe.Pont [I].Y := Mibol.Pont [I].Y;
    Mibe.Pont [I].Z := LongDiv (LongMul (SF, Mx)-LongMul (CF,Mz), Szorzo);
  end;
end;

Procedure zForgat (Var Mibol, Mibe, Eredeti: PontoBJ;Fok: Integer);
Var I    : Integer;
    Mx   : Integer;
    My   : Integer;
    SF   : Integer;
    CF   : Integer;
begin
  For I := 0 to Eredeti.PontSzam-1 Do
  begin
    Mx := Mibol.Pont [I].x;
    My := Mibol.Pont [I].y;
    SF := SinT [Fok];
    CF := CosT [Fok];
    Mibe.Pont [I].X := LongDiv (LongMul (CF, Mx)+LongMul (SF, My), Szorzo);
    Mibe.Pont [I].Y := LongDiv (LongMul (SF, Mx)-LongMul (CF, My), Szorzo);
    Mibe.Pont [I].Z := Mibol.Pont [I].Z;
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
    AktL: Integer;
    Sz2: String;
    R  : Real;

  Function SzamSzed (Mibol: String;Poz: Byte): Integer;
  Var I: Byte;
      Sz: String;
      ii: Integer;
      Szam: LongInt;
  begin
    Sz := '';
    I := Poz;
    While Mibol [I] in ['0'..'9'] Do
    begin
      Sz := Sz+Mibol [I];
      Inc (I);
    end;
    Val (Sz, Szam, II);
    SzamSzed := Szam;
  end;

begin
  Assign (T, 'fank.asc');
  Reset (T);
  AktP := 0;
  AktL := 0;
  While not (Eof (T)) Do
  begin
    Readln (T, Sz);
    If Pos ('Vertices:',Sz) > 0 then
    begin
      Sz2 := Copy (Sz, Pos ('Vertices:', Sz)+10,8);
      While Sz2 [Length (Sz2)] = #32 Do Dec (Sz2 [0]);
      Val (Sz2, Targy^.PontSzam, I);
    end;
    If Pos ('Faces:',Sz) > 0 then
    begin
      Sz2 := Copy (Sz, Pos ('Faces:', Sz)+7,8);
      While Sz2 [Length (Sz2)] = #32 Do Dec (Sz2 [0]);
      Val (Sz2, Targy^.LapSzam, I);
    end;
    If (Pos ('Vertex',Sz) > 0) and (Pos ('list',Sz) = 0) then
    begin
      Sz2 := Copy (Sz, Pos ('X:', Sz)+3, 6);
      Val (Sz2, R, I);
      Targy^.Pont [AktP].X := Round (R/5);
      Sz2 := Copy (Sz, Pos ('Y:', Sz)+3, 6);
      Val (Sz2, R, I);
      Targy^.Pont [AktP].Y := Round (R/5);
      Sz2 := Copy (Sz, Pos ('Z:', Sz)+3, 6);
      Val (Sz2, R, I);
      Targy^.Pont [AktP].Z := Round (R/5);
      Inc (AktP);
    end;
    If (Pos ('Face',Sz) > 0) and (Pos ('list',Sz) = 0) and (Pos ('Vertices',Sz) = 0) then
    begin
      Targy^.Lap [AktL].A := SzamSzed (Sz, Pos ('A:', Sz)+2);
      Targy^.Lap [AktL].B := SzamSzed (Sz, Pos ('B:', Sz)+2);
      Targy^.Lap [AktL].C := SzamSzed (Sz, Pos ('C:', Sz)+2);
      Inc (AktL);
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

Procedure SinINIT;
Var I   : Integer;
    Pipi: Real;
begin
  Pipi := (SinMax/2)/Pi;
  For I := 0 to SinMAX-1 Do
  begin
    SinT [I] := Trunc (Sin (I/(Pipi))*Szorzo);
    CosT [I] := Trunc (Cos (I/(Pipi))*Szorzo);
  end;
end;

Begin
  New (Temp);
  New (Temp2);
  New (Targy);
  Beolvas;
  SinInit;
  _320x200;
  New (HKep);
  PrgVege := False;
  InitSor;
  SzinBeallit;
  YPoz:= 200;
  Repeat
    HCls;
    Inc (Y,17);If Y >= SinMax then Y := Y-SinMax;
    Inc (X,13);If X >= SinMax then X := X-SinMax;
    Inc (Z,11);If Z >= SinMax then Z := Z-SinMax;
    yForgat (Targy^, Temp^, Targy^, Y);
    xForgat (Temp^, Temp2^, Targy^, X);
    zForgat (temp2^, Temp^, Targy^, z);
    Rajz (Temp^, Targy^);
    HRajz;
    B.Bill;
    Case B.C1 of
      #27: PrgVege := True;
    end;
  Until PrgVege;
  Dispose (HKep);
  Dispose (Targy);
  Dispose (Temp);
  Dispose (TEmp2);
  _80x25;
End.