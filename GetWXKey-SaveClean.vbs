'GetWXKey-SaveClean.vbs v1.0 | yacsap
'Modified to work with Windows 10, tested on Creators Update [Version 10.0.15063]
'Grab Windows 10 Key from Registry, and save the product key to user's desktop.

Option Explicit 

Dim strComputer, objWMIService, objItem, Caption, colItems
'Create wscript.shell object 
strComputer = "."
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select * from Win32_OperatingSystem",,48)
For Each objItem in colItems
    Caption = objItem.Caption  
Next
If InStr(Caption,"Microsoft Windows 10") > 0  Then 
                Dim objshell,path,DigitalID, Result 
                Set objshell = CreateObject("WScript.Shell")
                'Set registry key path
                Path = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\"
                'Registry key value
                DigitalID = objshell.RegRead(Path & "DigitalProductId")
                Dim ProductName,ProductID,ProductKey,ProductData
                'Get ProductName, ProductID, ProductKey
                ProductName = objshell.RegRead(Path & "ProductName")
                ProductID = objshell.RegRead(Path & "ProductID")
                ProductKey = ConvertToKey(DigitalID) 
                ProductData = ProductKey
                Save ProductData
End If 
'Convert binary to chars
Function ConvertToKey(Key)
    Const KeyOffset = 52
    Dim isWin8, Maps, i, j, Current, KeyOutput, Last, keypart1, insert
    'Check if OS is Windows 8
    isWin8 = (Key(66) \ 6) And 1
    Key(66) = (Key(66) And &HF7) Or ((isWin8 And 2) * 4)
    i = 24
    Maps = "BCDFGHJKMPQRTVWXY2346789"
    Do
                Current= 0
        j = 14
        Do
           Current = Current* 256
           Current = Key(j + KeyOffset) + Current
           Key(j + KeyOffset) = (Current \ 24)
           Current=Current Mod 24
            j = j -1
        Loop While j >= 0
        i = i -1
        KeyOutput = Mid(Maps,Current+ 1, 1) & KeyOutput
        Last = Current
    Loop While i >= 0 
    keypart1 = Mid(KeyOutput, 2, Last)
    insert = "N"
    KeyOutput = Replace(KeyOutput, keypart1, keypart1 & insert, 2, 1, 0)
    If Last = 0 Then KeyOutput = insert & KeyOutput
    ConvertToKey = Mid(KeyOutput, 1, 5) & "-" & Mid(KeyOutput, 6, 5) & "-" & Mid(KeyOutput, 11, 5) & "-" & Mid(KeyOutput, 16, 5) & "-" & Mid(KeyOutput, 21, 5)
   
    
End Function
'Save data to a file
Function Save(Data)
    Dim fso, fName, txt,objshell,UserName
    Set objshell = CreateObject("wscript.shell")
    'Get current user name 
    UserName = objshell.ExpandEnvironmentStrings("%UserName%") 
    'Create a text file on desktop 
    fName = "C:\Users\" & UserName & "\Desktop\WindowsKeyInfo.txt"
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set txt = fso.CreateTextFile(fName)
    txt.Write Data
    txt.Close
End Function
