###   PRESS RUN
###   You will be prompted for all the necessary information.



# Asks the script user to enter the End User and Mirror's username and domain.
Write-Host " "
Write-Host " Enter the Domain of your End User and Mirror. " -ForegroundColor Black -BackgroundColor White
Write-Host " Example: [Insert Examples]"
Write-Host " "
$mydomain = Read-Host -Prompt "  Domain"
Write-Host " "
Write-Host " Enter the Username of your Mirror. " -ForegroundColor Black -BackgroundColor White
Write-Host " "
$endUserUsername = Read-Host -Prompt "  End User's Username"
Write-Host " "
Write-Host " Enter the Username of your End User. " -ForegroundColor Black -BackgroundColor White
Write-Host " "
$mirrorUsername = Read-Host -Prompt "  Mirror's Username"

#Space 
Write-Host " "
Write-Host " "

# Input the Mirror and Enduser's username and fill in the correct server.
$Mirror = Get-ADUser $mirrorUsername -Server $mydomain
$EndUser = Get-ADUser $endUserUsername -Server $mydomain

# Copy the Mirror's Groups.
$mirrorGroups = Get-ADPrincipalGroupMembership -Server $mydomain -Identity $Mirror

# Add the Mirror's Groups to the End User.
$addedGroups = @()
$failedGroups = @()

foreach ($group in $mirrorGroups) {
    try {
        # Use -MemberOf $group.DistinguishedName to pass the group's DistinguishedName.
        Add-ADPrincipalGroupMembership -Server $mydomain -Identity $EndUser -MemberOf $group.DistinguishedName
        $addedGroups += $group.DistinguishedName
    } catch {
        $failedGroups += $group.DistinguishedName
    }
}

#Space 
Write-Host " "
Write-Host "_________________________________________________________"
Write-Host " "

# Display the added groups.
Write-Host "  Groups that DID ADD to the End User: "  -ForegroundColor Black -BackgroundColor White
$addedGroups | ForEach-Object { Write-Host "  $_" -ForegroundColor White -BackgroundColor Green } 

#Space 
Write-Host " "

# Display the failed groups.
Write-Host "  Groups that FAILED to add to the End User: " -ForegroundColor Black -BackgroundColor White
$failedGroups | ForEach-Object { Write-Host "  $_" -ForegroundColor White -BackgroundColor Red }
