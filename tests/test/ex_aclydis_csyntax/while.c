
Begin

 While  Manufacturers[i].ID !=0
     BeginWhile
       If  Manufacturers[i].ID = = InAudioCardCaps[j].wMid
    Then
     wsprintf ( szMessage, "%s\0", Manufacturers[i].Name );
     break;
    Else
        i++;
     EndIf
 EndWhile

End
