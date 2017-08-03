function Add-Path() {
    [Cmdletbinding()]
    param([parameter(Mandatory=$True,ValueFromPipeline=$True,Position=0)][String[]]$AddedFolder)
    # Get the current search path from the environment keys in the registry.
    $OldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
    # See if a new folder has been supplied.
    if (!$AddedFolder) {
        Return 'No Folder Supplied. $ENV:PATH Unchanged'
    }
    # See if the new folder exists on the file system.
    if (!(TEST-PATH $AddedFolder))
    { Return 'Folder Does not Exist, Cannot be added to $ENV:PATH' }cd
    # See if the new Folder is already in the path.
    if ($ENV:PATH | Select-String -SimpleMatch $AddedFolder)
    { Return 'Folder already within $ENV:PATH' }
    # Set the New Path
    $NewPath=$OldPath+’;’+$AddedFolder
    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $newPath
    # Show our results back to the world
    Return $NewPath
}
######################################################
# Install Hyper-V
######################################################
Write-Host "Installing Hyper-V"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
Write-Host

######################################################
# Install apps using Chocolatey
######################################################
Write-Host "Installing Chocolatey"
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Write-Host

Write-Host "Installing applications from Chocolatey"
cinst git -y
cinst nodejs -y
cinst PhantomJS -y
cinst poshgit -y
cinst GoogleChrome -y
cinst firefox-dev -pre -y
cinst fiddler4 -y
cinst filezilla -y
cinst dropbox -y
cinst Evernote -y
cinst lastpass -y
cinst javaruntime-preventasktoolbar -y
cinst tortoisesvn -y
cinst micro -y
cinst 7zip.install
cinst adobereader -y
cinst jdk8 -y
cinst vlc -y
cinst paint.net
cinst itunes -y
cinst windirstat
cinst visualstudiocode
cinst sourcetree -y
cinst cmder -y
cinst docker-for-windows
cinst spotify -y
cinst jq -y
cinst yarn -y
cinst ilspy -y
cinst slack -y
cinst psake -y
cinst linqpad -y
cinst p4merge -y
cinst selenium-all-drivers -y
cinst zeal.install -y
#cinst usbdeview -y
#cinst visualstudio2017professional
#cinst beyondcompare
#cinst resharper
#cinst dotcover

Write-Host

######################################################
# Set environment variables
######################################################
Write-Host "Setting home variable"
[Environment]::SetEnvironmentVariable("HOME", $HOME, "User")
[Environment]::SetEnvironmentVariable("CHROME_BIN", "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "User")
[Environment]::SetEnvironmentVariable("PHANTOMJS_BIN", "C:\tools\PhanomJS\phantomjs.exe", "User")
Write-Host

######################################################
# Install SQL Express 2014
######################################################
Write-Host
do {
    $createSiteData = Read-Host "Do you want to install SQLExpress? (Y/N)"
} while ($createSiteData -ne "Y" -and $createSiteData -ne "N")
if ($createSiteData -eq "Y") {
    cinst mssqlserver2014express
}
Write-Host

######################################################
# Add Git to the path
######################################################
Write-Host "Adding Git\bin to the path"
Add-Path "C:\Program Files (x86)\Git\bin"
Write-Host

######################################################
# Configure Git globals
######################################################
Write-Host "Configuring Git globals"
$userName = Read-Host 'Enter your name for git configuration'
$userEmail = Read-Host 'Enter your email for git configuration'

& 'C:\Program Files (x86)\Git\bin\git' config --global user.email $userEmail
& 'C:\Program Files (x86)\Git\bin\git' config --global user.name $userName

$gitConfig = $home + "\.gitconfig"
Add-Content $gitConfig ((new-object net.webclient).DownloadString('http://bit.ly/mygitconfig'))

$gitexcludes = $home + "\.gitexcludes"
Add-Content $gitexcludes ((new-object net.webclient).DownloadString('http://bit.ly/gitexcludes'))
Write-Host

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

######################################################
# Install npm packages
######################################################
Write-Host "Install NPM packages"
npm install -g yo
Write-Host

######################################################
# Generate public/private rsa key pair
######################################################
Write-Host "Generating public/private rsa key pair"
Set-Location $home
$dirssh = "$home\.ssh"
mkdir $dirssh
$filersa = $dirssh + "\id_rsa"
ssh-keygen -t rsa -f $filersa -q -C $userEmail
Write-Host

######################################################
# Download custom PowerShell profile file
######################################################
Write-Host "Creating custom $profile for Powershell"
if (!(test-path $profile)) {
    New-Item -path $profile -type file -force
}
Add-Content $profile ((new-object net.webclient).DownloadString('http://bit.ly/profileps'))
Write-Host