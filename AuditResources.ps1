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
git remote set-url origin https://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@github.com/jhtut/AzureRmPipeline-repo.git
git config --global user.email 'joe.htut@gmail.com'
git config --global user.name 'Joe Htut'
git add --all 
git diff --quiet && git diff --staged --quiet || git commit -am '[skip ci] commit from CI runner"'
git push origin HEAD:main
