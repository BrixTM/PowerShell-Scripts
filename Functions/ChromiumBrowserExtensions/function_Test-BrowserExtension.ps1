function Test-BrowserExtension {
    [CmdletBinding(DefaultParameterSetName = 'Both')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Edge')]
        [switch]$TestEdge,
        [Parameter(Mandatory, ParameterSetName = 'Chrome')]
        [switch]$TestChrome,
        [Parameter(Mandatory, ParameterSetName = 'Both')]
        [switch]$Testboth,
        [Parameter(Mandatory, ParameterSetName = 'Both')]
        [Parameter(Mandatory, ParameterSetName = 'Chrome')]
        [String]$ChromeExtensionID,
        [Parameter(Mandatory, ParameterSetName = 'Both')]
        [Parameter(Mandatory, ParameterSetName = 'Edge')]
        [String]$EdgeExtensionID
    )
    #Tests if the registry Hive for browser extension install exists, if not create it
    $CurrentUser = ((Get-CimInstance -class Win32_ComputerSystem | Select-Object username).username) -replace '^[^\\]+\\', ''
    $UserAccounts = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
    $DesiredUser = foreach ($UserAccount in $UserAccounts) {
        Get-ItemProperty -path "Registry::$($UserAccount.name)" | Where-Object { $_.ProfileImagePath -match $CurrentUser }
    }
    #loops through each user identified that matches the current users username, this also counts admin accounts because we use -match to filter
    foreach ($user in $DesiredUser) {
        #Gets a list of all the extensions within the registry hive and creates a custom object for then as get-itemproperty does not format as an object for reg keys correctly
        $ChromeExtensions = Get-ItemProperty -Path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Google\Chrome\ExtensionInstallForcelist" | ForEach-Object {
            foreach ($ChromepropertyName in $_.PSObject.Properties.Name) {
                #Filters out any of the default properties returned by get-itemproperty that we dont want
                if ($ChromepropertyName -notlike "PS*") {
                    $Chromevalue = Get-ItemPropertyValue -Path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name $ChromepropertyName
                    [pscustomobject]@{
                        Name  = $ChromepropertyName
                        Value = $Chromevalue
                    }
                }
            }
        }
        #Gets a list of all the extensions within the registry hive and creates a custom object for then as get-itemproperty does not format as an object for reg keys correctly
        $EdgeExtensions = Get-ItemProperty -Path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" | ForEach-Object {
            foreach ($EdgepropertyName in $_.PSObject.Properties.Name) {
                #Filters out any of the default properties returned by get-itemproperty that we dont want
                if ($EdgepropertyName -notlike "PS*") {
                    $Edgevalue = Get-ItemPropertyValue -Path "Registry::HKEY_USERS\$($User.PSChildName)\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -Name $EdgepropertyName
                    [pscustomobject]@{
                        Name  = $EdgepropertyName
                        Value = $Edgevalue
                    }
                }
            }
        }
    }
    #Checks if the extension exists within the list for Chrome and sets a variable to True or False depending on if the filter returns Null
    if ($null -ne ($ChromeExtensions | Where-Object { $_.value -match $ChromeExtensionID })) {
        $Chrometest = $true
    }
    else {
        $Chrometest = $False
    }
    #Checks if the extension exists within the list for Edge and sets a variable to True or False depending on if the filter returns Null
    if ($null -ne ($EdgeExtensions | Where-Object { $_.value -match $EdgeExtensionID })) {
        $Edgetest = $true
    }
    else {
        $Edgetest = $False
    }

    #If you choose to test both, will check if both test variable are true and return successful, if not it will return a fail
    if ($Testboth) {
        if ($Edgetest -and $Chrometest) {
            Write-Host "Chrome and Edge Detected Successfully"
            Exit 0 
        }
        else {
            Write-Host "Chrome and Edge not detected"
            Exit 1
        }
    }
    #If you choose to test Chrome, will check if the Chrome test variable are true and return successful, if not it will return a fail
    if ($TestChrome) {
        if ($Chrometest) {
            Write-Host "Chrome Detected Successfully"
            Exit 0
        }
        else {
            Write-Host "Chrome not detected"
            Exit 1
        }
    }
    #If you choose to test Edge, will check if the Edge test variable are true and return successful, if not it will return a fail
    if ($TestEdge) {
        if ($Edgetest) {
            Write-Host "Chrome Detected Successfully"
            Exit 0
        }
        else {
            Write-Host "Chrome not detected"
            Exit 1
        }
    }

}
