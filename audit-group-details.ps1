# Connect to Exchange Online
connect-ExchangeOnline

# Get all groups
$groups = Get-UnifiedGroup -ResultSize Unlimited

# initialize variable for group settings used for csv output later
$groupsettings = @()

# Loop through each group
Foreach($group in $groups){

    # Get group members and subscribers
    $members = Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Members -ResultSize Unlimited
    $Owners = Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Owners -ResultSize Unlimited

    # Create new object for output
    $groupsetting = [PSCustomObject]@{
        Name = $group.displayname
        Email = $group.PrimarySmtpAddress
        MemberCount = $members.count
        SubscriberCount = $subscribers.count
        Members = $members.PrimarySmtpAddress -join ','
        MembersId = $members.ExchangeObjectId -join ','
        Owners = $owners.PrimarySmtpAddress -join ','
        OwnersId = $owners.ExchangeObjectId -join ','
        SharePointSiteUrl = $group.SharePointSiteUrl
        SiteAccessType = $group.AccessType
        WelcomeMessageEnabled = $group.WelcomeMessageEnabled
    }

    # Add new object to output array
    $groupsettings += $groupsetting
}

# Export output to CSV
$dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
$filePath = ".\memberaudit_$dateTime.csv"
$groupsettings | Export-Csv -Path $filePath -NoTypeInformation
