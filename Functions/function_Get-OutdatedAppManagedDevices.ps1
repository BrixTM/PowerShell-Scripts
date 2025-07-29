function Get-OutdatedAppDevices
{
    [CmdletBinding()]
    param (
    [Parameter(Mandatory)]
    [String]$AppDisplayName,
    [Parameter(Mandatory)]
    [String]$AppVersion,
    [Parameter(Mandatory)]
    [validateset('Windows','androidworkprofile','ios','AndroidDeviceAdministrator','AndroidFullyManagedDedicated','MacOS','Other')]
    [String]$AppPlatform
    )

    #These variable are here if you need to test the function
    #$AppDisplayName = 'Google Chrome'
    #$AppVersion = '137.0.7151.69'
    #$AppPlatform = 'Windows' #Note - Only accepts one of the above validateset arguments

    #Gets all discovered applications and gets the details of the specified group
    Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All",'DeviceManagementManagedDevices.Read.All' -NoWelcome
    $DetectedInstalls = Get-MgDeviceManagementDetectedApp -All

    #Filters the detected apps down to the specified app using device name as well as setting the version of the object to [system.version] rather than a string (this was a pain in the ass)
    $fixedobject = $DetectedInstalls | Where-Object DisplayName -match $AppDisplayName | Where-Object Platform -match $AppPlatform | ForEach-Object {
        [PSCustomObject]@{
            Displayname = $_.DisplayName
            ID = $_.Id
            Version = [system.version]($_.version -replace '\(.*\)','')
            platform = $_.Platform
        } 
    }
    #Filters down futher by less than the specified version
    $FilteredInstall = $fixedobject | Where-Object Version -LT $AppVersion

    #Gets all the devices apart of the detected apps 
    ForEach ($AppInstall in $FilteredInstall) {
        Get-MgDeviceManagementDetectedAppManagedDevice -DetectedAppId $AppInstall.id -All
        Start-Sleep 5
    }
}