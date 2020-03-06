unit MyClasses;

interface

uses
  Classes, Tags;

{
  Есть в паскале т.н. классовые функции/процедуры и блоки
   обработки исключений. Так вот они неверно подсвечиваются
   (имеется в виду возможность подсветки парных скобок/тэгов)
   Пытаюсь сейчас сам разобраться, как можно модифицировать
   hrc, но пока надежды мало.
}
(*
sdfsadf
*)

(*$I+*) //!! <-- кстати, это тоже директива компилятора. как и
{$I+}
        //       и мне ее тоже задать пока не удалось.

type         //┌─ !!подсвечивается сам по себе, без пары
  TClass1 = class(TMyObject)
    class function TagSupported(const Tag: TagType): Boolean;
  end;//┴── !!подсвечиваются в паре

function CopyList(List: TList): TList;

implementation//<─── !!подсвечивается сам по себе, без пары

uses
  SysUtils;

function CopyList(List: TList): TList;
var
  i: Integer;
begin//<───────────────────────────────────────────────────────────────────┐
  Result := TList.Create;                       //                         │


  try
     try
     except
     end

  except
  end

  try //──────── !!подсв. с ─>──────────────────────────────────────┐      │
    if List <> nil then                         //                  │      │
      for i := 0 to List.Count - 1 do           //                  │      │
        Result.Add(TMyObject.CreateAssign(TMyObject(List[i])));//   │      │
  except                                        //                  │      │
    Result.Free;                                //                  │      │
    raise;                                      //                  │      │
  end;                                          //                  │      │
  Result.Capacity := Result.Count;              //                  │      │
  //       └────────────────┴── !! и еще - как убрать подсветку     │      │
  //                   белым с полей и методов объектов и записей?  │      │
  //                   в сишном тексте такого нет...                │      │
end;//<─────────────────────────────────────────────────────────────┘      │
//└───────────── !!подсв. с ─>─────────────────────────────────────────────┘

{ TClass1 }

//┌────<── !!подсв. с ──>─────────────────────────────────────────────┐
class function TClass1.TagSupported(const Tag: TagType): Boolean; //  │
begin                                                             //  │
  Result := TagIn(Tag, [TClass1Tag, TClass11Tag]);                //  │
end;                                                              //  │
                                                                  //  │
initialization //<──── !!вообще не подсвечивается                 //  │
  RegisterClass(TClass1);                                         //  │
finalization //<──── !!вообще не подсвечивается                   //  │
  UnRegisterClass(TClass1);                                       //  │
end.//──<── !!подсв. с ─>─────────────────────────────────────────────┘
