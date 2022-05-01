<#
.Synopsis
    Create wsb xml config file.

.DESCRIPTION
    This script generates a .wsb config file for the windows sandbox application with xml syntax. Please read throught the reference article on the provided link
    to get information about the used parameters of this script. 
    This configuration provides only one shared folder. You can not share more than one by using this script. I made this adjustment because i never needed more than one folder.
    If you need more than one you need to change the config file like shown on the provided link.
    Every switch is set to a default that suits my configurations if you need other default config you need to change the parameters in the script itself. Not using the switches will set the config to
    the default values.
    The sandbox username is <WDAGUtilityAccount> so you need to specify a sandbox parameter like shown below.
    To use your created config double click on your config file or use my Enable-WindowsSandBoxOrStartRoH.ps1 script.

    Microsoft refrence link:

    https://docs.microsoft.com/de-de/windows/security/threat-protection/windows-sandbox/windows-sandbox-configure-using-wsb-file

.EXAMPLE
    This example creates a windows sandbox with my defaults.

    .\Create-WIndowsSandboxXmlRoH.ps1 -CreateWsbFile ~\PS-Scripts\WindowsDefaultSandbox.wsb

    Config:

    <Configuration>
      <vGPU>Enable</vGPU>
      <Networking>Enable</Networking>
      <MappedFolders>
        <MappedFolder>
          <HostFolder>
          </HostFolder>
          <SandboxFolder>
          </SandboxFolder>
          <ReadOnly>false</ReadOnly>
        </MappedFolder>
      </MappedFolders>
      <LogonCommand>
        <Command>
        </Command>
      </LogonCommand>
      <AudioInput>Disable</AudioInput>
      <VideoInput>Disable</VideoInput>
      <ProtectedClient>Enable</ProtectedClient>
      <PrinterRedirection>Disable</PrinterRedirection>
      <ClipboardRedirection>Enable</ClipboardRedirection>
      <MemoryInMB>
      </MemoryInMB>
    </Configuration>

.EXAMPLE
    Every path related switch should be used with quotes especially with blanks in it. 

    .\Create-WIndowsSandboxXmlRoH.ps1 -CreateWsbFile ~\PS-Scripts\WindowsDefaultSandbox.wsb -VGpu Disable -Networking Disable -LogonCommand "explorer.exe C:\Users\WDAGUtilityAccount\Downloads" -AudioInput Enable -VideoInput Enable -ProtectedClient Disable -PrinterRedirection Enable -ClipboardRedirection Disable -HostFolder "~\PS-Scripts" -SandboxFolder "C:\Users\WDAGUtilityAccount\Downloads" -ReadOnly true

    Config:

    <Configuration>
      <vGPU>Disable</vGPU>
      <Networking>Disable</Networking>
      <MappedFolders>
        <MappedFolder>
          <HostFolder>C:\Users\ExampleUser\PS-Scripts</HostFolder>
          <SandboxFolder>C:\Users\WDAGUtilityAccount\Downloads</SandboxFolder>
          <ReadOnly>true</ReadOnly>
        </MappedFolder>
      </MappedFolders>
      <LogonCommand>
        <Command>explorer.exe C:\Users\WDAGUtilityAccount\Downloads</Command>
      </LogonCommand>
      <AudioInput>Enable</AudioInput>
      <VideoInput>Enable</VideoInput>
      <ProtectedClient>Disable</ProtectedClient>
      <PrinterRedirection>Enable</PrinterRedirection>
      <ClipboardRedirection>Disable</ClipboardRedirection>
      <MemoryInMB>
      </MemoryInMB>
    </Configuration>

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='CreateWSBConfigXml', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='CreateWSBConfigXml',
    Position=0,
    Mandatory,
    HelpMessage='Create wsb file. Use literal path. File needs the .wsb extension.')]
    [String]$CreateWsbFile,

    [Parameter(
    ParameterSetName='CreateWSBConfigXml',
    Position=0,
    HelpMessage='Enable vgpu. Default = Enabled')]
    [ValidateSet("Enable","Disable")]
    [String]$VGpu = "Enable",

    [Parameter(
    ParameterSetName='CreateWSBConfigXml',
    Position=0,
    HelpMessage='Disable Network.')]
    [ValidateSet("Enable","Disable")]
    [String]$Networking = "Enable",
    
    [Parameter(
    ParameterSetName='CreateWSBConfigXml',
    Position=0,
    HelpMessage='Host folder that will be mapped in the sandbox.')]
    [String]$HostFolder,

    [Parameter(
    ParameterSetName='CreateWSBConfigXml',
    Position=0,
    HelpMessage='Path where host folder will be mapped in the sandbox.')]
    [String]$SandboxFolder,

    [Parameter(
    ParameterSetName='CreateWSBConfigXml',
    Position=0,
    HelpMessage='Permission on the mapped folder. True = Read only, False = Read write. Default = "false".')]
    [ValidateSet("true","false")]
    [String]$ReadOnly = "false",

    [Parameter(
    ParameterSetName='CreateWSBConfigXml',
    Position=0,
    HelpMessage='Executable or script that is run on logon. Example: C:\Windows\System32\cmd.exe.')]
    [String]$LogonCommand = "",

    [Parameter(
    ParameterSetName='CreateWSBConfigXml',
    Position=0,
    HelpMessage='Enable audio input. Default = "Disable".')]
    [ValidateSet("Enable","Disable")]
    [String]$AudioInput = "Disable",

    [Parameter(
    ParameterSetName='CreateWSBConfigXml',
    Position=0,
    HelpMessage='Enable video input. Default = "Disable".')]
    [ValidateSet("Enable","Disable")]
    [String]$VideoInput = "Disable",

    [Parameter(
    ParameterSetName='CreateWSBConfigXml',
    Position=0,
    HelpMessage='Runs sandbox with higher security standards. Default = "Enable"')]
    [ValidateSet("Enable","Disable")]
    [String]$ProtectedClient = "Enable",

    [Parameter(
    ParameterSetName='CreateWSBConfigXml',
    Position=0,
    HelpMessage='Enable printer redirection.')]
    [ValidateSet("Enable","Disable")]
    [String]$PrinterRedirection = "Disable",

    [Parameter(
    ParameterSetName='CreateWSBConfigXml',
    Position=0,
    HelpMessage='Disable printer redirection.')]
    [ValidateSet("Enable","Disable")]
    [String]$ClipboardRedirection = "Enable",

    [Parameter(
    ParameterSetName='CreateWSBConfigXml',
    Position=0,
    HelpMessage='Memory for the sandbox in megabytes(MB).')]
    [Int32]$Memory
)
if($CreateWsbFile){
    New-Item -Path "$CreateWsbFile" -Force

    $WsbDefaultConfig = 
"<Configuration>
<vGPU></vGPU>
<Networking></Networking>
<MappedFolders>
  <MappedFolder> 
    <HostFolder></HostFolder> 
    <SandboxFolder></SandboxFolder> 
    <ReadOnly></ReadOnly> 
  </MappedFolder>
</MappedFolders>
<LogonCommand>
  <Command></Command>
</LogonCommand>
<AudioInput></AudioInput>
<VideoInput></VideoInput>
<ProtectedClient></ProtectedClient>
<PrinterRedirection></PrinterRedirection>
<ClipboardRedirection></ClipboardRedirection>
<MemoryInMB></MemoryInMB>
</Configuration>
"

$WsbDefaultConfig | Out-File -LiteralPath $CreateWsbFile -Encoding utf8 -Force
}

[System.Reflection.Assembly]::LoadWithPartialName("System.Xml")
$WsbXml = [System.Xml.XmlDocument]::new()
$WsbXml.Load("$CreateWsbFile")
$WsbXml.Configuration.vGPU = $VGpu
$WsbXml.Configuration.Networking = $Networking
$WsbXml.Configuration.MappedFolders.FirstChild.HostFolder = $HostFolder
$WsbXml.Configuration.MappedFolders.FirstChild.SandboxFolder = $SandboxFolder
$WsbXml.Configuration.MappedFolders.FirstChild.ReadOnly = $ReadOnly
$WsbXml.Configuration.LogonCommand.Command = $LogonCommand
$WsbXml.Configuration.AudioInput = $AudioInput
$WsbXml.Configuration.VideoInput = $VideoInput
$WsbXml.Configuration.ProtectedClient = $ProtectedClient
$WsbXml.Configuration.PrinterRedirection = $PrinterRedirection
$WsbXml.Configuration.ClipboardRedirection = $ClipboardRedirection
$WsbXml.Save("$CreateWsbFile")
