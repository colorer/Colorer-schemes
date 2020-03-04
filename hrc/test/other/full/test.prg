/*
 Кодовый блок
*/

 CodeBloc := {|a1,a2| AdSay(1,2, a1+Str(a2,3)) }

/*
Массив
*/
    Array := {"1",.f., {"123", 0, NIL} }

/*
Смешанные
*/

  ArrayCodeBlock := { {|a1|  Test(A1)=1001 },;
                      {123, 456, "234243"}   ;
                    }

  CodeBlockAndArray := {|Arr1,Numb| IIF( ASCAN(Arr1,Numb),;
                                         {"Найдено"},;
                                         {"Ошибка!","Значение не найдено"};
                                       );
                       }
