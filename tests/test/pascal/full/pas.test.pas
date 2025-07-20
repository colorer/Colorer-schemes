(***************************************************
ssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssss
***************************************************)

******* вырезать в test.pas ******* -----------------------------8<------------

  if Pos(ReplaceDialog1.FindText,  Memo1.Text) <> 0 then


program Test_Colors;

{
Добавить в список зарезервированных слов Delphi (Pascal.Hrc):
  cdecl
  stdcall
  pascal
  register
  safecall
  default
  nodefault
  message
  read
  write
}

{ Приколы с asm-блоком в Pascal'e
  Пишу, потому что сам Borland выделяет правильно! :-) }
procedure TestAsmBlock1; {проверка asm-блока}
begin
  asm
   loop1:   {это метка}
   @@loop2: {это метка}
   @loop:   {это тоже метка, а цветом не выделилась}
;      inc dx      {эта строка НЕ закомметирована, а цветом выделяется}
                   {здесь ';' - "пустой" оператор}
//      inc dx      эта строка закомметирована, цветом не выделяется
    mov ah, 1       {это комметарий в asm-блоке, цветом не выделяется}
    int 16h
    or ah, ah
    je @end         {здесь '@end' метка, а не зарезервированное слово}
    jmp @loop
   @end:            {это та же метка}
    mov Variable, 2
  end;
  WriteLn(Variable);
end;

procedure TestAsmBlock21; {еще примерчик}
begin
  if Variable = 1 then
  begin
    Variable := 0;
    asm
     @loop:
      mov ah, 1; int 16h;  {так тоже можно писать, а выделяется неправильно}
      or ah, ah
      je @end
      jmp @loop
     @end:
    end            {здесь после 'end' - ';' не обязательна, но это конец блока}
  end else         {это пошел уже не asm-блок}
    Variable := 1;
  Inc(Variable); WriteLn(Variable);
end;

procedure TestAsmBlock22; {та же процедурка с маленьким изменением}
begin
  if Variable = 1 then
  begin
    Variable := 0;
    asm
     @loop:
      mov ah, 1
      int 16h
      or ah, ah
      je @end
      jmp @loop
     @end:
    end           {это тоже конец блока}
  end else
    Variable := 1;
  Inc(Variable); WriteLn(Variable);
end;

begin
  Ch := #32;  {это символ пробела}
  Ch := #$20; {это тоже символ пробела, но он не выделился}
  f := 4.93e33;
  i := $3fa33;
  i :=$3fa33;   // ? :=
  i := 23..33;
  i := 984;
  5.4 0.  $3Fg
  5.4 0.
  safecall 23
  // from tst.asm
  1.  .1
  1. .1         // <?
  1..1
  1. .....1...1
  0...1e2
  1.1.1e-1
  ).3
.3 .3()
3.
3.(dfd)
    3e3
end.



// Tested on Colorer 2.8

//  БАГИ с "end"

 begin

    asm
        xor eax,eax
        // sdffffdsfdfds
 end;
  //
 end;
  //

begin
 asm
     xor ax,ax
     //  xor ax,ax
 end;
end;


// А ЗДЕСЬ ВСЕ ОК. Какая то зависимость от отступа ( при сдвиге "end" влево/вправо ).

 begin

    asm
        xor eax,eax
        // sdffffdsfdfds
  end;

 end;


begin
 asm
     xor ax,ax
     //  xor ax,ax
  end;
end;
