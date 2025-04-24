#Install:
powershell.exe -windowstyle hidden -executionpolicy bypass .\Function_New-Shortcut.ps1

#Uninstall:
#Note Icons are not removed from the device.
powershell.exe -command 
if(test-path ([Environment]::GetFolderPath('Desktop')+'\Shortcut.lnk')) {Remove-Item ([Environment]::GetFolderPath('Desktop')+'\Shortcut.lnk')} 
if(test-path ([Environment]::GetFolderPath('StartMenu')+'\Shortcut.lnk')) {Remove-Item ([Environment]::GetFolderPath('StartMenu')+'\Shortcut.lnk')} 
if(test-path ('C:\ProgramData\Microsoft\Windows\Start Menu\Programs'+'\Shortcut.lnk')) {Remove-Item ('C:\ProgramData\Microsoft\Windows\Start Menu\Programs'+'\Shortcut.lnk')} 

exit 0
