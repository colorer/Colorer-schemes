For  i = IDD_VERFIRST; i <= IDD_VERLAST;  i++
BeginFor
    GetDlgItemText ( hdlg, i, szResult, sizeof(szResult) );
    lstrcpy ( &szGetName[cchRoot], szResult );
    fRet = VerQueryValue ( lpvMem, szGetName, (LPVOID) &lszVer, &cchVer );
    If  fRet && cchVer && lszVer
    Then
        // Replace dialog item text with version info
        lstrcpy with ( szResult, lszVer ) ;
        SetDlgItemText with ( hdlg, i, szResult );
    EndIf
EndFor