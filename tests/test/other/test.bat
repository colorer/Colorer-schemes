
rem Another issue I won't dare fixing on my own is that in a line like this:

 SET GenerateDate=FOR /F "usebackq tokens=2" %%a IN (`ECHO %DATE%') DO SET CurDate=%%a

rem the highlighting started from behind echo spans until the end of the line,
rem though it should terminate in this context at the closing `.
rem (And since you can use for /f (without the option usebackq) with ' instead of ` with
rem the same effect this might require another rule as well.

rem Another issue are calls to subroutines. Those are written like this:

:mySub
echo Hey, I got a param: %1
goto :EOF

rem and can be called via

call :mySub param1 param2 ...

rem In this case the :mySub is not being highlighted as it would be the case with
	
goto mySub