# Find all users with all attributes in specified ou.
# Distinguished name of the organizational unit.
$OU = "<DistinguishedName>"
$ADObjSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
$ADObjSearcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry($OU)
$ADObjSearcher.Filter = "(&(objectCategory=User))"
$ADObjSearcher.SearchScope = "Subtree"
$ADUsers = $ADObjSearcher.FindAll()

# Return samaccountname of all users.
$ADUsers | ForEach-Object{
    $SamAccountName = $_.Properties["samaccountname"]
    $SamAccountName
}

# Find a specific group.
# Only the own scope is used.
$ADObjSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
$DomainObj = New-Object System.DirectoryServices.DirectoryEntry
$ADObjSearcher.SearchRoot = $DomainObj
# Use different scope e.g. country.
# $ADObjSearcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry('LDAP://DC=country,DC=domain,DC=com')
#
# $DomainObj = New-Object System.DirectoryServices.DirectoryEntry('LDAP://DC=country,DC=domain,DC=com')
# $ADObjSearcher.SearchRoot = $DomainObj

$ADObjSearcher.Filter = "(&(objectClass=group) (CN=*<Groupname>*))"
$ADObjSearcher.SearchScope = "Subtree"
$ADUser = $ADObjSearcher.FindAll()
$ADUser

# Get member of specific group
# Search for user with specified name and return all attributes.
$ADObjSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
$DomainObj = New-Object System.DirectoryServices.DirectoryEntry
$ADObjSearcher.SearchRoot = $DomainObj
$ADObjSearcher.Filter = "(&(objectClass=user)(SamAccountName=*)(memberof=<distinguishedname of group>))"
$ADObjSearcher.SearchScope = "Subtree"
# Specify attributes you would like to retrieve.
$FilterAttributes = ("userprincipalname","title")
$ADObjSearcher.PropertiesToLoad.AddRange($FilterAttributes)
$ADUser = $ADObjSearcher.FindAll()
$ADUser.Properties

# Search for user with specified name and return all attributes.
# Look for all objects, where the specified samaccountname is part of.
$ADSISearcher = New-Object System.DirectoryServices.DirectorySearcher 
$ADSISearcher.Filter = "(SamAccountName=*<SamAccountName>*)"
$ADSISearcher.FindOne()

# Search for user with specified name and return all attributes.
$ADObjSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
$DomainObj = New-Object System.DirectoryServices.DirectoryEntry
$ADObjSearcher.SearchRoot = $DomainObj
$ADObjSearcher.Filter = "(&(objectClass=user) (SamAccountName=*<SamAccountName>*))"
$ADObjSearcher.SearchScope = "Subtree"
$ADUser = $ADObjSearcher.FindAll()
$ADUser

# Search for user with specified name and return specified attributes.
$ADObjSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
$DomainObj = New-Object System.DirectoryServices.DirectoryEntry
$ADObjSearcher.SearchRoot = $DomainObj
$ADObjSearcher.Filter = "(&(objectClass=user) (SamAccountName=*<SamAccountName>*))"
$ADObjSearcher.SearchScope = "Subtree"

# Specify attributes you would like to retrieve.
$FilterAttributes = ("telephone*", "mail", "department")
$ADObjSearcher.PropertiesToLoad.AddRange($FilterAttributes)
$ADUser = $ADObjSearcher.FindAll()
foreach ($Attribute in $ADUser.Properties.PropertyNames){
    Write-Host $Attribute , "=" , $ADUser.Properties.$Attribute
}

# Search for user with specified name and return specified attributes.
$ADObjSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
$DomainObj = New-Object System.DirectoryServices.DirectoryEntry
$ADObjSearcher.SearchRoot = $DomainObj
$ADObjSearcher.Filter = "(&(objectClass=user) (SamAccountName=*<SamAccountName>*))"
$ADObjSearcher.SearchScope = "Subtree"

# Specify attributes you would like to retrieve.
$FilterAttributes = ("samaccountname","telephonenumber", "mail", "department")
$ADObjSearcher.PropertiesToLoad.AddRange($FilterAttributes)
$ADUser = $ADObjSearcher.FindAll()
foreach($Attribute in $ADUser.Properties.Propertynames){
    $ADUserObj = New-Object PSCustomObject
    Add-Member -InputObject $ADUserObj -MemberType NoteProperty -Name "Attributes" -Value $Attribute
    Add-Member -InputObject $ADUserObj -MemberType NoteProperty -Name "Properties" -Value $($ADUser.Properties.$Attribute)
    $ADUserObj
}

# Specify attributes you would like to retrieve.
$FilterAttributes = ("samaccountname","telephonenumber", "mail", "department")
# $FilterAttributes = ("*")
$ADObjSearcher.PropertiesToLoad.AddRange($FilterAttributes)
$ADUser = $ADObjSearcher.FindAll()
$ADUserObj = New-Object PSCustomObject
foreach($Attribute in $ADUser.Properties.Propertynames){
    Add-Member -InputObject $ADUserObj -MemberType NoteProperty -Name $Attribute -Value $($ADUser.Properties.$Attribute) -Force
}
$ADUserObj
Clear-Variable ADUserObj

# Find all Server with all attributes using root domain.
$DomainObj = New-Object System.DirectoryServices.DirectoryEntry
$OU = "LDAP://" + $DomainObj.distinguishedName.ToString()
#$OU = "LDAP://OU=company,DC=domain,DC=local"
$ADObjSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
$ADObjSearcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry($OU)
$ADObjSearcher.Filter = "(&(objectCategory=Computer)(OperatingSystem=*Server*))"
$ADObjSearcher.SearchScope = "Subtree"
$ADComputer = $ADObjSearcher.FindAll()
# Return dnshostname of all computers.
$ADComputer| ForEach-Object{
    $SamAccountName = $_.Properties["DnsHostName"]
    $SamAccountName | Sort-Object Name
}

# Find all Server with all attributes using root domain.
$DomainObj = New-Object System.DirectoryServices.DirectoryEntry
$OU.GetType() = "LDAP://" + $DomainObj.distinguishedName.ToString()
#$OU = "LDAP://OU=company,DC=domain,DC=local"
$ADObjSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
$ADObjSearcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry($OU)
$ADObjSearcher.Filter = "(&(objectCategory=Computer) (OperatingSystem=*Server*))"
$ADObjSearcher.SearchScope = "Subtree"
$ADComputer = $ADObjSearcher.FindAll()
# Return samaccountname of all computers.
$LDAPServerArray = @()
$ADComputer | ForEach-Object{
    $LDAPServerInfos = New-Object PSCustomObject
    Add-Member -InputObject $LDAPServerInfos -MemberType NoteProperty -Name SamAccountName -Value $($_.Properties["samaccountname"])
    $LDAPServerArray += $LDAPServerInfos
}
$LDAPServerArray

# Find all Server with specific attributes using root domain.
$DomainObj = New-Object System.DirectoryServices.DirectoryEntry
$OU.GetType() = "LDAP://" + $DomainObj.distinguishedName.ToString()
#$OU = "LDAP://OU=company,DC=domain,DC=local"
$ADObjSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
$ADObjSearcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry($OU)
$ADObjSearcher.Filter = "(&(objectCategory=Computer) (OperatingSystem=*Server*))"
$ADObjSearcher.SearchScope = "Subtree"
# Specify attributes you would like to retrieve.
$FilterAttributes = ("DNSHostname","OperatingSystem")
$ADObjSearcher.PropertiesToLoad.AddRange($FilterAttributes)
$ADComputer = $ADObjSearcher.FindAll()
# Return attributes of all computers.
$LDAPServerArray = @()
$ADComputer | ForEach-Object{
    $LDAPServerInfos = New-Object PSCustomObject
    Add-Member -InputObject $LDAPServerInfos -MemberType NoteProperty -Name DnshostName -Value $($_.Properties["DNSHostName"])
    Add-Member -InputObject $LDAPServerInfos -MemberType NoteProperty -Name OperatingSystem -Value $($_.Properties["OperatingSystem"])
    $LDAPServerArray += $LDAPServerInfos
}
$LDAPServerArray

# Find all clients that don't have a server operatingsystem using root domain.
$DomainObj = New-Object System.DirectoryServices.DirectoryEntry
$OU.GetType() = "LDAP://" + $DomainObj.distinguishedName.ToString()
#$OU = "LDAP://OU=company,DC=domain,DC=local"
$ADObjSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
$ADObjSearcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry($OU)
# (!( is a not operator.
$ADObjSearcher.Filter = "(&(objectCategory=Computer) (!(OperatingSystem=*Server*)))"
$ADObjSearcher.SearchScope = "Subtree"
$ADComputer = $ADObjSearcher.FindAll()
# Return samaccountname of all computers.
$LDAPServerArray = @()
$ADComputer | ForEach-Object{
    $LDAPServerInfos = New-Object PSCustomObject
    Add-Member -InputObject $LDAPServerInfos -MemberType NoteProperty -Name SamAccountName -Value $($_.Properties["samaccountname"])
    $LDAPServerArray += $LDAPServerInfos
}
$LDAPServerArray

# Get ad root.
$DomainObj = New-Object System.DirectoryServices.DirectoryEntry
$DomainObj
# Get all ous in AD.
$DomainObj = New-Object System.DirectoryServices.DirectoryEntry
$DomainObj.Children.DistinguishedName

# Get infos without domain join with username and password.
# Username, Password need to be from type string.
$LDAPAuthenticationType = New-Object System.DirectoryServices.AuthenticationTypes
$LDAPSEARCH = New-Object System.DirectoryServices.DirectorySearcher #-Property @{SearchRoot = 'LDAP://DC=Example,DC=LOCAL'}
$LDAPSEARCH.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry('LDAP://Server.example.local',$UserName,$Password)
$LDAPSEARCH.SearchScope = 'Subtree'
$LDAPSEARCH.Filter = "(SamAccountName=*$env:ComputerName*)"
$LDAPSEARCH.FindAll()

# Get infos without domain join.
$LDAPAuthenticationType = New-Object System.DirectoryServices.AuthenticationTypes
$LDAPSEARCH = New-Object System.DirectoryServices.DirectorySearcher #-Property @{SearchRoot = 'LDAP://DC=Example,DC=LOCAL'}
$LDAPSEARCH.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry('LDAP://Server.example.local')
$LDAPSEARCH.SearchScope = 'Subtree'
#$LDAPSEARCH.Filter = "(SamAccountName=*$env:ComputerName*)"
$LDAPSEARCH.FindAll()

# Deactivate user via LDAP.
#[System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.AccountManagement")
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$PrincipalContext = [System.DirectoryServices.AccountManagement.PrincipalContext]::new([System.DirectoryServices.AccountManagement.ContextType]::Domain)
$Principal = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($PrincipalContext, "<UserPrincipalName>")
$Principal.Enabled = $false
$Principal.Save()

#--------------------------------------Not tested------------------------------------------------------

# Get infos without domain join.
# Get all Domain controller.
$LDAPSEARCH = New-Object System.DirectoryServices.DirectorySearcher
$LDAPSEARCH.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry((”LDAP://rootdse”).ConfigurationNamingContext)
$LDAPSEARCH.SearchScope = 'Subtree'
$LDAPSEARCH.Filter = "(&(objectCategory=domain))"
($LDAPSEARCH.FindAll()).GetDirectoryEntry() | Select-Object -ExpandProperty msDs-IsDomainFor
#($LDAPSEARCH.FindAll() | Select-Object -ExpandProperty Properties)."msds-isdomainfor"

[adsi]”LDAP://rootdse” | Select-Object domainFunctionality,domainControllerFunctionality

# Get infos without domain join.
# Get all Domain controller.
$LDAPSEARCH = New-Object System.DirectoryServices.DirectorySearcher
$LDAPSEARCH.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry((”LDAP://Servername/DC=domain,DC=local”,"<Userpripalname>","<password>"))
$LDAPSEARCH.SearchScope = 'Subtree'
$LDAPSEARCH.Filter = "(&(objectCategory=domain))"
($LDAPSEARCH.FindAll()).GetDirectoryEntry()