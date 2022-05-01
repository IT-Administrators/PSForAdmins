<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Start best practice analyzer"
''
#Get-BPAModel | ft ID,Name,Version,Modeltype -AutoSize
''
#$BPAModels = Get-BPAModel | ft ID,Name,Version,Modeltype -AutoSize
#Retrieving the installed best practice models and filtering for the id's.
$BPAModelsID = (Get-BpaModel).ID
#Starts a best practices scan for every installed model. 
foreach($BPAModel in $BPAModelsID){
Invoke-BpaModel -BestPracticesModelId $BPAModel
}
foreach($BPAResult in $BPAModelsID){
<#Returning every scan result where severity equals error. These are the only results we are interested in because error results from the models might 
cause huge trouble in maintaing the functionality of your network.#>
Get-BpaResult -BestPracticesModelId $BPAResult -Filter 'Severity -eq "Error"' | Format-List ModelID,Severity,Category,Title,Problem,Impact,Resolution,Help
}