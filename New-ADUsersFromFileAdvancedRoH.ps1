<#
.Synopsis
    Create domain users from file

.DESCRIPTION
    This script creates users from a specified file. The example file looks like shown underneath. The users are created in the organizational unit you specify in your file. You can even use sub ou's but than
    you need the literal path.
    The password and userfile parameters are mandatory. All other parameters are not mandatory. Every line in your file is a seperate array, so if you want to use more information
    while creating users you have to adjust the script. If you don't want some of these informations you have to adjust the script or you can use a blank with ";" as delimiter. 
    I would recommend trying this script with one user before running it on a bunch.     
    Accounts that just have one name won't be created. All users must match the pattern (shown below): <FirstName LastName>

    I used a txt file with the format shown underneath because not every server has software that can open or modify .csv files. With this file you can even use this script on a core server. Modifying a text file with
    the console is much more pleasant than a csv fíle.

    Be careful with your users file. If you use a file like shown underneath the created users are sorted by firstname 1) or lastname 2):
        
    1) ExampleDomainUsers.txt 

    Brad Pitt
    Leonardo DiCaprio
    Sean Connery
    Eddy Murphy
    Hulk Hogan

    The text file has to look like this:
     
    FirstName LastName;Department;PhoneNumber;MailDomain;LogonDomain;OU;ADGroupName;

    Brad Pitt;Oceans 11;PhoneNumber;ExampleMailDomain.com;LogonDomain.com;OU=ExampleUsers,DC=ExampleDomain,DC=Com;ExampleGroup1,ExampleGroup2,ExampleGroup3;


    2) ExampleDomainUsers.txt 
    
    Black Jack
    Connery Sean
    DiCaprio Leonardo
    Hill Terence     
    Hogan Hulk
    Pitt Brad           
    Spencer Bud    
    
    The text file has to look like this:
    
    LastName FirstName;Department;PhoneNumber;MailDomain;LogonDomain;OU;ADGroupName;
     
    Pitt Brad;Oceans 11;PhoneNumber;ExampleMailDomain.com;LogonDomain.com;OU=ExampleUsers,DC=ExampleDomain,DC=Com;ExampleGroup1,ExampleGroup2,ExampleGroup3;

.Example 
    The homedirectory input doesn't need a "\" at the end. Otherwise the homedirectory looks like \\ExampleDomain-File\Data\\UserName.
    
    .\New-ADUsersFromFileAdvancedRoH.ps1 -ADDomainUserDefaultPW Example1234! -ADDomainUserFile "C:\Temp\ExampleDomainUsers.txt" -NewOUForADUsers TestUsers -ADUserHomeDrive H: -ADUserHomeDirectory \\ExampleDomain-File\Data -ADUserLogonScript C:\LogonScripts\LogonScript.bat

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='ADDomainUsers', 
               SupportsShouldProcess=$true)]

param(
    [Parameter(
    ParameterSetName='ADDomainUsers',
    Position=0,
    Mandatory,
    HelpMessage='Password for all domain users.')]
    [String]$ADDomainUserDefaultPW,

    [Parameter(
    ParameterSetName='ADDomainUsers',
    Position=0,
    Mandatory,
    HelpMessage='File that contains the users.')]
    [String]$ADDomainUserFile,

    [Parameter(
    ParameterSetName='ADDomainUsers',
    Position=0,
    HelpMessage='Ou that will be created if this parameter is used.')]
    [String]$NewOUForADUsers,

    [Parameter(
    ParameterSetName='ADDomainUsers',
    Position=0,
    HelpMessage='Letter the homedirectory is linked to.')]
    [String]$ADUserHomeDrive,

    [Parameter(
    ParameterSetName='ADDomainUsers',
    Position=0,
    HelpMessage='Home directory of all users.')]
    [String]$ADUserHomeDirectory,

    [Parameter(
    ParameterSetName='ADDomainUsers',
    Position=0,
    HelpMessage='Logon script directory.')]
    [String]$ADUserLogonScript
)

$Password = ConvertTo-SecureString $ADDomainUserDefaultPW -AsPlainText -Force
$UserCreationFile = Get-Content "$ADDomainUserFile"

foreach($User in $UserCreationFile){

    $Name = $User.Split(";")[0]
    $FirstName = $Name.Split(" ")[0]
    $LastName = $Name.Split(" ")[1]
    $SamAccountName = "$($FirstName.Substring(0,1)).$($LastName)"
    $DisplayName = "$LastName, $FirstName"
    $Department = $User.Split(";")[1]
    $PhoneNumber = $User.Split(";")[2]
    $EMail = $User.Split(";")[3]
    $LogonDomain = $User.Split(";")[4]
    $OU = $User.Split(";")[5]
    $ADGroups = $User.Split(";")[6]

    if($EMail -eq ""){
        $UserMail = ""
    }
    else{
        $UserMail = "$SamAccountName@$EMail"
    }

    if($LogonDomain -eq ""){
        $LogonDomain = $env:USERDNSDOMAIN
    }

    Write-Output "Creating user: $($DisplayName)"
    
    New-ADUser `
                -AccountPassword $Password `
                -GivenName $FirstName `
                -Surname $LastName `
                -Name $DisplayName `
                -DisplayName $DisplayName `
                -UserPrincipalName $SamAccountName@$LogonDomain `
                -SamAccountName $SamAccountName `
                -EmailAddress $UserMail `
                -OfficePhone $PhoneNumber `
                -Department $Department `
                -HomeDrive $ADUserHomeDrive `
                -HomeDirectory $ADUserHomeDirectory\$SamAccountName `
                -ScriptPath "$ADUserLogonScript" `
                -ChangePasswordAtLogon $true `
                -Path $OU `
                -Enabled $true

    $ADGroups.Split(",") | ForEach-Object{Add-ADGroupMember -Identity $_ -Members $SamAccountName}
}
