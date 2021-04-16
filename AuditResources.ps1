# Prepare Git
git config --global user.email 'joe.htut@gmail.com'
git config --global user.name 'Joe Htut'
git checkout

# Declare variable for CSV files
$allResources = @()

# Get Subscription Name
$Subscription = Get-AzContext
$SubscriptionName = $Subscription.Subscription.Name

# Delete existing folder if exists
If(Test-Path -path $SubscriptionName)
{
    Remove-Item -LiteralPath $SubscriptionName -Force -Recurse
}

# Get all the resources under subscription
$resources = Get-AzResource

foreach ($resource in $resources)
{
    $filename = ($pwd).path+"/"+$SubscriptionName+"/"+$resource.ResourceGroupName+"/"+$resource.Name+".json"
    $filename = $filename.Replace(' ' , '_')
    $filename = $filename.Replace('[' , '_')
    $filename = $filename.Replace(']' , '_')
    Export-AzResourceGroup -ResourceGroupName $resource.ResourceGroupName -Resource $resource.ResourceId -Path $filename -Force
    $customPsObject = New-Object -TypeName PsObject
    $subscription = Get-AzSubscription -SubscriptionName $SubscriptionName
    $tags = $resource.Tags.Keys + $resource.Tags.Values -join ':'
    $customPsObject | Add-Member -MemberType NoteProperty -Name Subscription -Value $subscription.Name
    $customPsObject | Add-Member -MemberType NoteProperty -Name ResourceGroup -Value $resource.ResourceGroupName
    $customPsObject | Add-Member -MemberType NoteProperty -Name ResourceName -Value $resource.Name
    $customPsObject | Add-Member -MemberType NoteProperty -Name ResourceType -Value $resource.ResourceType
    $customPsObject | Add-Member -MemberType NoteProperty -Name Location -Value $resource.Location
    $customPsObject | Add-Member -MemberType NoteProperty -Name Tags -Value $tags
    $customPsObject | Add-Member -MemberType NoteProperty -Name Sku -Value $resource.Sku
    $allResources += $customPsObject
}

# Export Resources details to csv file
$allResources | Export-Csv ./resource-audit.csv -NoTypeInformation

# Commit files to Git
git add --all 
git diff --quiet && git diff --staged --quiet || git commit -am '[skip ci] commit from CI runner"'
git push origin HEAD:main
