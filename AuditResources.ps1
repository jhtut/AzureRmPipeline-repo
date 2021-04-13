$allResources = @()
$SubscriptionName = "Pay-As-You-Go"
Select-AzSubscription -SubscriptionName $SubscriptionName
$resources = Get-AzResource
foreach ($resource in $resources)
{

    $filename = ($pwd).path+"\"+$resource.ResourceGroupName+"\"+$resource.Name+".json"
    Export-AzResourceGroup -ResourceGroupName $resource.ResourceGroupName -Resource $resource.ResourceId -Path $filename
    $customPsObject = New-Object -TypeName PsObject
    $subscription = Get-AzSubscription -SubscriptionName $SubscriptionName
    $tags = $resource.Tags.Keys + $resource.Tags.Values -join ':'
    $customPsObject | Add-Member -MemberType NoteProperty -Name Subscription -Value $subscription.Name
    $customPsObject | Add-Member -MemberType NoteProperty -Name ResourceName -Value $resource.Name
    $customPsObject | Add-Member -MemberType NoteProperty -Name ResourceGroup -Value $resource.ResourceGroupName
    $customPsObject | Add-Member -MemberType NoteProperty -Name Location -Value $resource.Location
    $customPsObject | Add-Member -MemberType NoteProperty -Name ResourceType -Value $resource.ResourceType
    $customPsObject | Add-Member -MemberType NoteProperty -Name Tags -Value $tags
    $customPsObject | Add-Member -MemberType NoteProperty -Name Sku -Value $resource.Sku
    $allResources += $customPsObject
}
$allResources | Export-Csv .\resource-audit.csv -NoTypeInformation
