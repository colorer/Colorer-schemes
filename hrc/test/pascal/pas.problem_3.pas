// для схемы: ...\hrc\main\pascal.hrc
//
// Проблема. Ключевое слово inherited не выделено как ключевое.
// Видно , что проблема в обрамляющих скобках...
//
class function F(x: Integer): Integer;
function G(x: Integer): Integer;
class procedure P(x: Integer);
procedure Q(x: Integer);

function TRect.LoadFromStream(S: IStream): TBool;
begin
    Result := ( inherited LoadFromStream(S)) and  // Problem !!!
              //^^^^^^^^^
              A.LoadFromStream(S) and B.LoadFromStream(S)
    ;
end;


function TRect.LoadFromStream(S: IStream): TBool;
begin
    Result := inherited LoadFromStream(S) // OK !!!
    ;        //^^^^^^^^
end;

