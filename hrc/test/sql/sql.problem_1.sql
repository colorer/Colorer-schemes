/*
   Проблема с выделением(подсветкой) "скобок"

  начало: "create or replace package (.)* is"
            здесь надо еще исключть вариант:
                 "create or replace package body (.)* is"
  конец:   end 
*/

create or replace package TTT is

-- ...

end;


create
or replace package TTT is

-- ...С переводом строки уже не работает, хотя указано: create(\s)*or(\s)*replace...

end;


