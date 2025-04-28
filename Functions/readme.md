<p align="center"> 
    <img src="https://media.tenor.com/dc1V2uGIXgAAAAAj/seseren-blue-archive.gif" width="100"/> 
    <img src="https://media.tenor.com/dc1V2uGIXgAAAAAj/seseren-blue-archive.gif" width="100"/> 
    <img src="https://media.tenor.com/dc1V2uGIXgAAAAAj/seseren-blue-archive.gif" width="100"/> 
    <img src="https://media.tenor.com/dc1V2uGIXgAAAAAj/seseren-blue-archive.gif" width="100"/> 
    <img src="https://media.tenor.com/dc1V2uGIXgAAAAAj/seseren-blue-archive.gif" width="100"/> 
</p>

# Functions
This folder contains a bunch of functions I've made, some may be apart of other scripts in the parent Directory. I should update this when I add new functions with a description of them.

##### Get-ManagedDeviceDetails
- Used to gather information about devices from Intune and Azure using mgraph, this required the mgraph and mgraph beta PS modules to be present.
- Can search devices based of various different options such as Hostname, IMEI, OS, Serial Number, AzureID, IntuneID and ObjectID.
- Returns as a custom object that should be easy to work with and pass into other scripts.

##### Get-OutdatedAppManagedDevices
- Used to get a list of devices from intune with app versions older than what you specify
- The version number can be a bit messy depending on how apps handle their versioning, i would recommend testing -LT as [system.version] for your specific apps.

##### Install-NetworkPrinters
- Allows you to auto install printers from network print servers that match a devices subnet.
- Can filter out specific printers, for example if you use papercut you may want to filter out Follow Me printers.
- Will check if a printer is already installed and if there are no network printers on that subnet.
- There is a folder for this function in the Parent directory which contains earlier versions before I turned the app into a function, was used as an intune remediation. 
