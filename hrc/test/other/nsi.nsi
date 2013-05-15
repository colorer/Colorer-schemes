Function "asdfasdf"

.onInit

un.onUserAbort

FunctionEnd

Function DownloadIfNeeded
;-----------------------------------------------------------------------------
  pop $Name  ; Filename
  pop $section  ; section

  
  SectionGetFlags $section $0
  IntOp $0 $0 & ${SF_SELECTED}
  IntCmp $0 ${SF_SELECTED} +1 SkipDL

  ; check if file already exists
  IfFileExists "$EXEDIR\$Name" SkipDL
  inetc::get /RESUME "" "http://downloads.sourceforge.net/mingw/$Name" "$EXEDIR\$Name" /END
  Pop $0
  StrCmp $0 "OK" DownLoadOK

  ; can we recover from this now?

  detailprint $0
  Abort "Could not download $Name!"

SkipDL:
  DetailPrint "File already exists - skipping $Name."
  Sleep 1000

DownLoadOK:
FunctionEnd
