//  Пример возможных структур кодовых блоков / массивов
//
//
//
//
SetWidth
Size
&& lalalala

BrowseArray(1,5,;
            {|| ADvm_Header(" Месяц "), ;
                ADvm_Keys({K_F1, K_F5, K_F9}, {|n, k| BA_KeyHandle(n,k)}),;
                // закрылся второй кодовы блок ... и соответственно
                // закрылась раскраска и первого
                ADvm_extra(,;
                            {|| BA_StatusLine(1), ADvm_versbar()},;
                          );
            },; // на самом деле первый КБ должен закрываться здесь
            aListLK,;
            {|nLine, sLine,KolLine| OnEnterMonth(nLine, sLine, KolLine)})

s1:={ {|| wwewe };   // также закрытие КБ приводит к закрытию и раскрасски массива
    }
//* и наоборот
cb:={|a1, a2|  A1=a2, {"223", 33} }  // и во вторых внутри КБ / массива
   // расскраска внутренних структу не производится, так же само как

Ss:={ {"wsasd", "qwqwqw"},;
      1,2,3 , ;
      {|wewe, wewe| "uyewtuytweury"} ;
    }

