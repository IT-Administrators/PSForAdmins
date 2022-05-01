<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script receives the windows product key. There are also comamnd for cmd and a vbs code to get the windows key.#>
"Windows product key"
''
(Get-WmiObject -query 'select * from SoftwareLicensingService‘).OA3xOriginalProductKey

#CMD Command
#wmic path softwarelicensingservice get OA3xOriginalProductKey

#VBS Command
#(echo Set WshShell = CreateObject^("WScript.Shell"^) & echo.MsgBox ConvertToKey^(WshShell.RegRead^("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DigitalProductId"^)^) & echo. & echo.Function ConvertToKey^(Key^) & echo.Const KeyOffset = 52 & echo.i = 28 & echo.Chars = "BCDFGHJKMPQRTVWXY2346789" & echo.Do & echo.Cur = 0 & echo.x = 14 & echo.Do & echo.Cur = Cur * 256 & echo.Cur = Key^(x + KeyOffset^) + Cur & echo.Key^(x + KeyOffset^) = ^(Cur ^\ 24^) And 255 & echo.Cur = Cur Mod 24 & echo.x = x -1 & echo.Loop While x ^>= 0 & echo.i = i -1 & echo.KeyOutput = Mid^(Chars, Cur + 1, 1^) ^& KeyOutput & echo.If ^(^(^(29 - i^) Mod 6^) = 0^) And ^(i ^<^> -1^) Then & echo.i = i -1 & echo.KeyOutput = "-" ^& KeyOutput & echo.End If & echo.Loop While i ^>= 0 & echo.ConvertToKey = KeyOutput & echo.End Function) > ./GetKey.vbs && GetKey.vbs
