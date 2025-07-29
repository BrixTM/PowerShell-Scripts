function Remove-BrowserExtension {
    param (
        [Parameter(Mandatory)]
        #Specifies the Extension ID to install using
        [String]$ExtensionID,
        [Parameter(Mandatory)]
        [validateset('Chrome', 'Edge')]
        #Specifies the browser the Extension is for
        [String]$Browser
    )
    #Gets the current user of the system so that we can identify their SID to modify only their profile in the registry
    $CurrentUser = ((Get-CimInstance -class Win32_ComputerSystem | Select-Object username).username) -replace '^[^\\]+\\', ''
    $UserAccounts = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
    $DesiredUser = foreach ($UserAccount in $UserAccounts) {
        Get-ItemProperty -path "Registry::$($UserAccount.name)" | Where-Object { $_.ProfileImagePath -match $CurrentUser }
    }
    #loops through each user identified that matches the current users username
    foreach ($User in $DesiredUser) {
        switch ($Browser) {
            'Chrome' {  
                #Gets a list of all the extensions within the registry hive and creates a custom object for then as get-itemproperty does not format as an object for reg keys correctly
                $Extensions = Get-ItemProperty -Path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Google\Chrome\ExtensionInstallForcelist" | ForEach-Object {
                    foreach ($propertyName in $_.PSObject.Properties.Name) {
                        #Filters out any of the default properties returned by get-itemproperty that we dont want
                        if ($propertyName -notlike "PS*") {
                            $value = Get-ItemPropertyValue -Path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name $propertyName
                            [pscustomobject]@{
                                Name  = $propertyName
                                Value = $value
                            }
                        }
                    }
                }
                #filters out the extensions to only match the specified extension ID and removes it for any identified, if there are duplicates this will also remove those.
                $UninstallExtension = $Extensions | Where-Object { $_.value -match $ExtensionID }
                $UninstallExtension | ForEach-Object { Remove-ItemProperty -path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -name $_.Name }
            }
            'Edge' {
                #Gets a list of all the extensions within the registry hive and creates a custom object for then as get-itemproperty does not format as an object for reg keys correctly
                $Extensions = Get-ItemProperty -Path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" | ForEach-Object {
                    foreach ($propertyName in $_.PSObject.Properties.Name) {
                        #Filters out any of the default properties returned by get-itemproperty that we dont want
                        if ($propertyName -notlike "PS*") {
                            $value = Get-ItemPropertyValue -Path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -Name $propertyName
                            [pscustomobject]@{
                                Name  = $propertyName
                                Value = $value
                            }
                        }
                    }
                }
                #filters out the extensions to only match the specified extension ID and removes it for any identified, if there are duplicates this will also remove those.
                $UninstallExtension = $Extensions | Where-Object { $_.value -match $ExtensionID }
                $UninstallExtension | ForEach-Object { Remove-ItemProperty -path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -name $_.Name }
            }
        }
    }
}