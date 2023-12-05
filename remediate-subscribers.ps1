#This script is intended to be run on a regular basis, to ensure that all members of a group are also subscribers. It will add any missing subscribers to the group, and export the results to a CSV file.

#The script uses the ExchangeOnline module, and will need to be run in a PowerShell session that has the ExchangeOnline module imported.

#The script can be run by opening a PowerShell session and running the following commands:
# .\AddMissingSubscribers.ps1

connect-ExchangeOnline

$Groups = Get-UnifiedGroup -ResultSize Unlimited

$MissingUsers = @()
Foreach($Group in $Groups){
    $Members = (Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Members -ResultSize Unlimited).Guid
    $Subscribers = (Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Subscribers -ResultSize Unlimited).Guid
    if($Members.Count - $Subscribers.Count -ne 0){
    $MissingSubscribers = $Members | Where-Object { $_ -notin $Subscribers }
    foreach ($Missing in $MissingSubscribers){
        Add-UnifiedGroupLinks -Identity $Group.Identity -LinkType Subscribers -Links $Missing.Guid
        $MissingUser = [pscustomobject]@{
            GroupName = $Group.DisplayName
            GroupEmail = $Group.PrimarySmtpAddress
            Subscriber = $Missing
            SubscriberEmail = (Get-Mailbox -Identity $Missing.Guid).PrimarySmtpAddress
        }
        $MissingUsers += $MissingUser
    }
}
else {
    Write-Host "No missing subscribers for group $($Group.DisplayName)"
}
}

$dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
$filePath = ".\missingSubscribers_$dateTime.csv"
$MissingUsers | Export-Csv -Path $filePath -NoTypeInformation
