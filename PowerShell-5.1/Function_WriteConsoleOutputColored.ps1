<#
.Synopsis
    Colors the output.

.DESCRIPTION
    This function colors the specified output in the chosen color. You can either color the background by using
    the <Background> parameter or the foreground if you don't use the <Background> parameter.
    The default color is red. You can adjust this by using the <Color> parameter.
    
    This function only runs as expected while using the powershell. It doesn't colord output in powershell_ise. 

.PARAMETER Background
    Colors the background of the specified output.

.PARAMETER Color
    Color in which the background is colored.

.PARAMETER OutputToColor
    Ouput that will be colored.

.EXAMPLE
    This example colores the specified background of the specified object in the default color red. 

    Write-ConsoleOutputColored -Background -OutputToColor Test

    Output:

    Test in front of red background.

.EXAMPLE
    This example colores the specified background of the specified object in the color blue.

    Write-ConsoleOutputColored -Background -Color blue -OutputToColor Test

    Output:

    Test in front of blue background.

.EXAMPLE
    This example colores the specified foreground of the specified object in the color blue.

    Write-ConsoleOutputColored -Color blue -OutputToColor Test

    Output:

    Test with foregroundcolor blue.

.EXAMPLE
    This example shows how to pipe object into the function.

    "Test" | Write-ConsoleOutputColored -Background

    Output:

    Test in front of red background.

.EXAMPLE
    This example shows that you can pipe an object into that function. But as you can see only one property of 
    the specified object is returned in red. If you want more than one property colored you need to build a [PSCustomObject], like
    shown in the next example.

    $PsDrives = Get-PSDrive | Where-Object {$_.Provider -match "FileSystem"}
    $PsDrives | ForEach-Object{$_ | Write-ConsoleOutputColored -Background}

    Output:
    C
    J
    P
    U
    
    All in front of red background.

.EXAMPLE
    This example shows a more advanced way to color your output. If there's only 1/4 of diskspace free on you drive
    the DriveName, Used and Free properties are colored. The colored results are enclosed in {}.
    Import that function into you session and than run the code from the example. If the requirements are met you will see colored output.

    ExampleCode:

    $PSDrives = Get-PSDrive | Where-Object {$_.Provider -match "FileSystem"}
    $DriveArray = @()
    foreach($Drive in $PSDrives){ 
        $PSDrivesObj = New-Object PSCustomObject
        Add-Member -InputObject $PSDrivesObj -MemberType NoteProperty -Name Name -Value ($Drive | ForEach-Object{
            if([Math]::Round($_.Free / 1GB,2) -lt [Math]::Round(([Math]::Round($_.Used / 1GB,2) + [Math]::Round($_.Free / 1GB,2)) /4,2)){
                $_.Name | Write-ConsoleOutputColored -Background
            }
            else{
                $_.Name
            }
        })
        Add-Member -InputObject $PSDrivesObj -MemberType NoteProperty -Name "Used (GB)" -Value ($Drive | ForEach-Object{
            if([Math]::Round($_.Free / 1GB,2) -lt [Math]::Round(([Math]::Round($_.Used / 1GB,2) + [Math]::Round($_.Free / 1GB,2)) /4,2)){
                [Math]::Round($_.Used / 1GB,2) | Write-ConsoleOutputColored -Background
            }
            else{
                [Math]::Round($_.Used / 1GB,2)
            }
        })
        Add-Member -InputObject $PSDrivesObj -MemberType NoteProperty -Name "Free (GB)" -Value ($Drive | ForEach-Object{
            if([Math]::Round($_.Free / 1GB,2) -lt [Math]::Round(([Math]::Round($_.Used / 1GB,2) + [Math]::Round($_.Free / 1GB,2)) /4,2)){
                [Math]::Round($_.Free / 1GB,2) | Write-ConsoleOutputColored -Background
            }
            else{
                [Math]::Round($_.Free / 1GB,2)
            }
        })
        Add-Member -InputObject $PSDrivesObj -MemberType NoteProperty -Name Provider -Value $Drive.Provider
        Add-Member -InputObject $PSDrivesObj -MemberType NoteProperty -Name Root -Value $Drive.DisplayRoot
        Add-Member -InputObject $PSDrivesObj -MemberType NoteProperty -Name CurrentLocation -Value $Drive.CurrentLocation
        $DriveArray += $PSDrivesObj
    }
    $DriveArray | Format-Table -AutoSize

    Output:

    Name      Used (GB)     Free (GB) Provider                             Root                                             CurrentLocation
    ----           ----          ---- --------                             ----                                             ---------------
    C            118,11        356,12 Microsoft.PowerShell.Core\FileSystem                                                  Users\ExampleUser
    {J}       {1841.83}      {158.16} Microsoft.PowerShell.Core\FileSystem \\ExampleFileServer\Shares\IT
    {P}       {1841.83}      {158.16} Microsoft.PowerShell.Core\FileSystem \\ExampleFileServer\Shares\Public
    {U}       {1841.83}      {158.16} Microsoft.PowerShell.Core\FileSystem \\ExampleFileServer\Shares\Userhome\ExampleUser



.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Write-ConsoleOutputColored {

    [CmdletBinding(DefaultParameterSetName='ColorConsoleOutput', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='ColorConsoleOutput',
        Position=0,
        HelpMessage="Choose what to color. If you don't use this switch, the foregroundcolor is set.")]
        [Switch]$Background,

        [Parameter(
        ParameterSetName='ColorConsoleOutput',
        Position=1,
        HelpMessage="Choose the color you want to use. Default = Red.")]
        [ValidateSet("Red","Blue","Green","Yellow")]
        [String]$Color = "Red",

        [Parameter(
        ParameterSetName='ColorConsoleOutput',
        Position=2,
        ValueFromPipeline,
        HelpMessage="The output you want to color.")]
        [Object]$OutputToColor
    )

    if ($Host.Name -match "ISE") {
        Write-Output "This script won't work properly in the PowerShell ISE. Run it in a PowerShell console."
    }

    if ($Background) {
        $X = 48
    }
    else {
        $X = 38
    }

    if ($PSVersionTable.PSEdition -eq "Core") {
        $Esc = "`e"
        $EscText = '`e'
    }
    else {
        $Esc = $([char]0x1b)
        $EscText = '$([char]0x1b)'
    }

    #Clear-Host

    if($Color -eq "Red"){
        $ChosenColor = 196
    }
    elseif($Color -eq "Blue"){
        $ChosenColor = 27
    }
    elseif($Color -eq "Green"){
        $ChosenColor = 40
    }
    elseif($Color -eq "Yellow"){
        $ChosenColor = 228
    }

    $ChosenColor | ForEach-Object {
        $Text = "{0}[$X;5;{1}m'$OutputToColor'{0}[0m" -f $EscText,$_
        
        "{1}" -f $Text,("$Esc[$X;5;$($_)m$($OutputToColor)$Esc[0m")
    }
}
