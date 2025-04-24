#-----------------Set Variables----------------
function get-subnet
{
   # Get client subnet
   if ($PSVersionTable.PSVersion.Major -ge 7)
    {
        $IP = Test-Connection -ComputerName (hostname) -count 1 -IPv4
        (($IP.Address.IPAddressToString.Split(".")[0,1,2] -join (".")[0,1,2]).replace(" ","")+".")
    }
    else {
        $IP = Test-Connection -ComputerName (hostname) -count 1 
        (($IP.IPV4Address.IPAddressToString.Split(".")[0,1,2] -join (".")[0,1,2]).replace(" ","")+".")
    }
}
#Get all the local printers
$LocalPrinters = get-printer

#Get the subnet of the device
$subnet = get-subnet

#Subnets of sites we want to check against, this was used as we only wanted to Install for Specific sites as a migration
$SiteSubnets = (
"1.2.3.4",
"2.3.4.5",
"3.4.5.6")

#Get the network printers on the device that match $subnet
$networkprinters = foreach ($server in @('PrintServer'))
{
    # Gather printers and them to variable
       get-printer -computername $server |Where-Object{$_.PortName -like "$subnet*" -and $_.Name -notlike "BadPrinter*"} -ErrorAction SilentlyContinue 
}
#----------------Start Script----------------

#Checks if the subnet has network printers, if not exit with 0,
#Checks if the subnet matches the specfified subnets, if not exit with code 0,
#Checks if the printer is already installed on the device, if yes exit with code 0, otherwise exit with code 1
if ($null -ne $networkprinters) {
    $ComparedPrinters = Compare-Object -ReferenceObject $networkprinters -DifferenceObject $LocalPrinters -Property PortName -IncludeEqual
    if ($SiteSubnets -contains $subnet) 
    {
        if ($ComparedPrinters.sideindicator -contains "<="){
            Write-Output "Device is missing network printer, adding $($networkprinters.name) to device"
            exit 1
        }
        else {
            Write-Output "Detected Printers already installed on device"
            Exit 0
        }
    }
    else {
        Write-Output "Incorrect Subnet, no printers added"
        Exit 0
    }
}
else {
    Write-Output "Subnet has no printers on Print Server"
    Exit 0
}