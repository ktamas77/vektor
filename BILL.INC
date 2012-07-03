Type BillTip = Object
       C1, C2: Char;
       Pressed: Boolean;
       ShPressed: Boolean;
       Procedure Bill;
       Procedure Varj;
       Function Shift: Boolean;
       Function Alt: Boolean;
     end;

Procedure BillTip.Bill;
begin
  C1 := #0;
  C2 := #0;
  If KeyPressed then
  begin
    C1 := ReadKey;
    If C1 = #0 then C2 := ReadKey;
    Pressed := True;
  end else Pressed := False;
  If Shift then ShPressed := True else ShPressed := False;
end;

Procedure BillTip.Varj;
begin
  While KeyPressed Do ReadKey;
  Repeat Until KeyPressed;
  While KeyPressed Do ReadKey;
end;

Function BillTip.Shift;
begin
  Shift := (Mem [$0000:$0417] and 3) <> 0;
end;

Function BillTip.Alt;
begin
  Alt := (Mem [$0000:$0417] and 8) = 8;
end;

