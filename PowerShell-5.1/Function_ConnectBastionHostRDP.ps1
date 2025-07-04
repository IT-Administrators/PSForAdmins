<#
.Synopsis
    Connects via RDP to a bastion host

.DESCRIPTION
    Connect via RDP to a bastion host located inside your azure.

    Use the <CheckPrerequisites> parameter to install or update the required modules.

.EXAMPLE
    Connect to bastion host via RDP.

    Connect-AzureBastionHostRDP -AzureVmName "ExampleVM" -BastionHostName "Example-Bastion" -TenantId "xxxxxxxx" -BastionSubscriptionId "xxxxxxxx" -BastionResourceGroup "ExampleDomain-RSG-Bastion" -Verbose
    
    Output:

    VERBOSE: Sent top=100 skip=0 skipToken=
    VERBOSE: Received results: 1
    VERBOSE: Found the VM.

    VERBOSE: Connected to Bastion Example-Bastion
    VERBOSE: Creating RDD profile.
    VERBOSE: GET with 0-byte payload
    VERBOSE: received -1-byte response of content type text/plain
    VERBOSE: Deleting the RDP file after use.
    VERBOSE: Performing the operation "Remove File" on target "%userprofile%\Desktop\ExampleVM-2024-04-16@140441.rdp".
    VERBOSE: Deleted %userprofile%\Desktop\ExampleVM-2024-04-16@140441.rdp.

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='ConnectAzureBastionHost', 
                SupportsShouldProcess=$true)]

param(
    [Parameter(
    ParameterSetName='ConnectAzureBastionHost',
    Position=0,
    HelpMessage='Azure VM name.')]
    [ValidateNotNullOrEmpty()]
    [string]$AzureVmName,

    [Parameter(
    ParameterSetName='ConnectAzureBastionHost',
    Position=1,
    HelpMessage='Bastion hostname.')]
    [string]$BastionHostName,

    [Parameter(
    ParameterSetName='ConnectAzureBastionHost',
    Position=2,
    HelpMessage='TenantId.')]
    [string]$TenantId,

    [Parameter(
    ParameterSetName='ConnectAzureBastionHost',
    Position=3,
    HelpMessage='Bastion subscription id.')]
    [string]$BastionSubscriptionId,

    [Parameter(
    ParameterSetName='ConnectAzureBastionHost',
    Position=4,
    HelpMessage='Bastion resource group.')]
    [string]$BastionResourceGroup,

    [Parameter(
    ParameterSetName='ConnectAzureBastionHost',
    Position=5,
    HelpMessage='Multimonitor or singlemonitor setup.')]
    [switch]$UseMultimonitor,

    [Parameter(
    ParameterSetName='ConnectAzureBastionHostModuleCheck',
    Position=0,
    HelpMessage='Required modules will be installed or updated.')]
    [switch]$CheckPrerequisites
)

if ($CheckPrerequisites){
    # Necessary modules for the RDP connection.
    $Modules = @("Az.accounts","Az.ResourceGraph","Az.Network")
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Verbose
    # Verify that modules are installed.
    foreach($module in $Modules){
        $ModuleCheck = Get-Module -Name $module -ListAvailable -All
        if ($ModuleCheck -ne $true){
            Find-Module -Name $module -Verbose | Install-Module -Scope CurrentUser -Verbose -Force
            Import-Module -Name $module -Scope Local -Verbose
        }
        else{
            Update-Module -Name $module -Verbose
            Import-Module -Name $module -Scope Local -Verbose
        }
    }
}
else{
    # Set executionpolicy to remotesigned to be able to import modules without any problem.
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Verbose
    
    # Import-Module -Name $Modules -Verbose
    Connect-AzAccount -Tenant $TenantId -Subscription $BastionSubscriptionId | Out-Null
        
    # Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Verbose

    # Query azure to find vm and get information about it.
    $VMToConnectTo = Search-AzGraph -Query "resources | extend PowerState = tostring(properties.extended.instanceView.powerState.code) | where type == 'microsoft.compute/virtualmachines' and name == '$AzureVmName'" -UseTenantScope
    $VmResourceId = $VMToConnectTo.ResourceId

    if (!([string]::IsNullOrEmpty($VmResourceId))) {
        Write-Verbose -Message "Found the VM." -Verbose
        # Check if machine is running otherwise exit.
        if ($VMToConnectTo.PowerState -eq 'PowerState/deallocated') {
            $User = [Environment]::UserName
            Write-Verbose -Message "The Vm is not running. Please start the vm." -Verbose
        }
        else {
            # Connect to the bastion sub in the correct tenant.
            Set-AzContext -SubscriptionId $BastionSubscriptionId -Tenant $TenantId 
            # Select-AzSubscription -SubscriptionId $BastionSubscriptionId -Tenant $TenantId | Out-Null
            # Get azure access token. The token is in securestring format now.
            # It must be resolved to use it as bearer token. 
            $AccessToken = (Get-AzAccessToken -AsSecureString).Token
            if (!([string]::IsNullOrEmpty($AccessToken))) {
                try {
                    # Get bastion information.
                    $Bastion = Get-AzBastion -ResourceGroupName $BastionResourceGroup -Name $BastionHostName
                    if ($null -ne $Bastion) {
                        Write-Verbose -Message "Connected to Bastion $($Bastion.Name)" -Verbose
                        Write-Verbose -Message "Creating RDP profile." -Verbose
                            
                        # Create endpoint (url) informations. This is later used to create the rdp file.
                        $TargetResourceId = $VmResourceId
                        $EnableMFA = "true"
                        $BastionEndpoint = $Bastion.DnsName
                        $ResourcePort = "3389"

                        $Url = "https://$($BastionEndpoint)/api/rdpfile?resourceId=$($TargetResourceId)&format=rdp&rdpport=$($ResourcePort)&enablerdsaad=$($EnableMFA)"

                        # Convert SecureString back to plain text for use. This must be done because the bearer token is specified in the header.
                        # In Powershell 7.0+ the Authentication parameter can be used. This doesnt require resolving the SecureString.
                        $PlainToken = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($AccessToken)
                        )

                        # Create authentication headers.
                        $Headers = @{
                            "Authorization"   = "Bearer $($PlainToken)"
                            "Accept"          = "*/*"
                            "Accept-Encoding" = "gzip, deflate, br"
                            #"Connection" = "keep-alive" #keep-alive and close not supported with PoSh 5.1 
                            "Content-Type"    = "application/json"
                        }
                        # Create RDP file informations.
                        $DesktopPath = [Environment]::GetFolderPath("Desktop")
                        $DateStamp = Get-Date -Format yyyy-MM-dd
                        $TimeStamp = Get-Date -Format HHmmss
                        $DateAndTimeStamp = $DateStamp + '@' + $TimeStamp 
                        $RdpPathAndFileName = "$DesktopPath\$AzureVmName-$DateAndTimeStamp.rdp"
                        $ProgressPreference = 'SilentlyContinue'
                    }
                    else {
                        Write-Verbose -Message "We could not connect to azure bastion host." -Verbose
                    }
                }
                catch {
                    Write-Error -Message "Internal error." -Category ObjectNotFound
                }
                    
                try {
                    $ProgressPreference = 'SilentlyContinue'
                    # Get RDP configfile informations.
                    Invoke-WebRequest $Url -Method Get -Headers $Headers -OutFile $RdpPathAndFileName -UseBasicParsing
                    $ProgressPreference = 'Continue'
                        
                    # Check if RDP config file exist and if yes start it.
                    if (Test-Path $RdpPathAndFileName -PathType Leaf) {
                        # Change from multimonitor to single.
                        if($UseMultimonitor -eq $false){
                            $RdpFileContent = Get-Content -Path $RdpPathAndFileName -Raw
                            $RdpFileContent.Replace("use multimon:i:1","use multimon:i:0") | Add-Content -Path $RdpPathAndFileName -Force -Verbose
                        }
                        Start-Process $RdpPathAndFileName -Wait
                        Write-Verbose -Message "Deleting the RDP file after use." -Verbose
                        Remove-Item $RdpPathAndFileName -Verbose
                        # Write-Verbose -Message "Deleted $RdpPathAndFileName." -Verbose
                        Set-ExecutionPolicy -ExecutionPolicy Default -Scope CurrentUser -Verbose
                    }
                    else {
                        Write-Verbose -Message "The RDP file was not found on your desktop." -Verbose
                    }
                }
                catch {
                    Write-Verbose -Message "An error occurred during the creation of the RDP file." -Verbose
                    $Error[0]
                }
                finally {
                    $ProgressPreference = 'Continue'
                }
            }
        }
    }
}
