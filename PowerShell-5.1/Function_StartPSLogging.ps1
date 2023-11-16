<#
.SYNOPSIS
    Create ps logging file.

.DESCRIPTION
    Create a logfile for powershell using the <Start-Transcript> cmdlet.

    Depending on the powershell version, other parameters can be used.

    I've written this script to learn about dynamic parameters.

.PARAMETER FilePath
    Either file or directory, where the log will be saved.

.PARAMETER UseMinimalHeader
    Only available in powershell 6 and higher.

.EXAMPLE
    Start logging by specifying a directory.

    If a directory is specified, the logfile is created automatically, with the following pattern:

    "Log" + "_" + $env:COMPUTERNAME + "_" + $env:USERNAME + "_" + (Get-Date -Format "ddMMyyyyHHmmss") + ".txt"

    If a file is specified and this file alredy exists, than the transcript is appended to the specified file.

    Start-PSLoggingRoH -FilePath $env:USERPROFILE\Downloads

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Start-PSLoggingRoH {
    
    [CmdletBinding(DefaultParameterSetName='PoShLogging', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='PoShLogging',
        HelpMessage='Filepath.')]
        [String]$FilePath = "$env:USERPROFILE\Documents"
    )

    DynamicParam{
        if($PSVersionTable.PSVersion.Major -gt 5){
            #Create parameter attributes
            $ParamAttributes = New-Object System.Management.Automation.ParameterAttribute
            $ParamAttributes.Mandatory = $false
            $ParamAttributes.ParameterSetName = "PoShLogging"

            #Create collection
            $ParamAttributesCol = New-Object 'System.Collections.ObjectModel.Collection[System.Attribute]'
            $ParamAttributesCol.Add($ParamAttributes)

            #Create dynamic parameter 1
            #Important is that the brackets are right behind the object, referencing the propertys one by one doesn't work
            $DynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter("UseMinimalHeader",[switch],$ParamAttributesCol)
           
            #Add param to dictionary
            $ParamDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $ParamDict.Add("UseMinimalHeader",$DynParam1)

            return $ParamDict
        }
    }
    begin{

        $UseMinimalHeader = $PSBoundParameters["UseMinimalHeader"]
    }
    process{
        if((Test-Path -Path $FilePath -PathType Leaf) -eq $true){
            
            $Transcript = $FilePath
            
            if($UseMinimalHeader){
                Start-Transcript -Path $Transcript -IncludeInvocationHeader -UseMinmalHeader -Append
            }
            else{
                Start-Transcript -Path $Transcript -IncludeInvocationHeader -Append
            }
        }
        else{
            $FileName = "Log" + "_" + $env:COMPUTERNAME + "_" + $env:USERNAME + "_" + (Get-Date -Format "ddMMyyyyHHmmss") + ".txt"
            $Transcript = $FilePath + "\" + $FileName

            if($UseMinimalHeader){
                Start-Transcript -Path $Transcript -IncludeInvocationHeader -UseMinmalHeader -Force
            }
            else{
                Start-Transcript -Path $Transcript -IncludeInvocationHeader -Force
            }
        }
    }
}