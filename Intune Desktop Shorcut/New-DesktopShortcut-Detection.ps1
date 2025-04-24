$shell = New-Object -ComObject WScript.Shell
Switch (test-path ($shell.SpecialFolders('Desktop')+'\shortcut.lnk'))
    {
        True {write-host "App is installed" 
                Exit 0
              }
        False {write-host "App Not Installed" 
                Exit 1
              }
    }