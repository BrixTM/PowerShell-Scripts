$shell = New-Object -ComObject WScript.Shell
$Desktop = test-path ($shell.SpecialFolders('Desktop')+'\Shortcut.lnk')
$StartMenu = test-path ($shell.SpecialFolders('StartMenu')+'\Shortcut.lnk')
$SystemStartMenu = Test-Path ('C:\ProgramData\Microsoft\Windows\Start Menu\Programs'+'\Shortcut.lnk')
$Icon = test-path "$env:LOCALAPPDATA\EUC\Icons\icon.ico"
$SystemIcon = test-path ("C:\Users\Default\AppData\Local\EUC\Icons\icon.ico")

<#
The test for the switch will need to be changed depending on what you want to check,
If you want to only test desktop, include only $Desktop
If you want to test both ensure to use -and
If you want to test for one or the other use -or
#>
Switch ($Desktop -and $StartMenu -and $icon -and $SystemStartMenu -and $SystemIcon)
    {
        True {write-host "App is installed" 
                Exit 0
              }
        False {write-host "App Not Installed" 
                Exit 1
              }
    }
