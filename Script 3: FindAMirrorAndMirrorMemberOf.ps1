###   PRESS RUN
###   You will be prompted for all the necessary information.


# Asks the script user to enter the Domain. Loops until a valid domain is entered.
do {
    Write-Host " "
    Write-Host " Enter the Domain of your End User and Mirror. " -ForegroundColor Black -BackgroundColor White
    Write-Host " Example: [Insert Examples]"
    Write-Host " "
    $mydomain = Read-Host -Prompt "  Domain"

    if ($mydomain -eq $null) {
        Write-Host " "
        Write-Host "  This is an invalid domain." -ForegroundColor Red
    } elseif (-not (Test-Connection -Count 1 -ComputerName $mydomain -Quiet)) {
        Write-Host " "
        Write-Host "  This is an unreachable domain." -ForegroundColor Red
    }
} while (-not (Test-Connection -Count 1 -ComputerName $mydomain -Quiet))


# Asks the script user to enter the End User's username. Loops until a valid username is entered.
do {
    Write-Host " "
    Write-Host " Enter the Username of your End User. " -ForegroundColor Black -BackgroundColor White
    Write-Host " "
    $endUserUsername = Read-Host -Prompt "  End User's Username"
    $EndUser = Get-ADUser -Filter {SamAccountName -eq $endUserUsername} -Server $mydomain

    if ($EndUser -eq $null) {
        Write-Host " "
        Write-Host "  This End User was not found in the $mydomain domain." -ForegroundColor Red
    }
} while ($EndUser -eq $null)

# Find the End User.
$endUser = Get-ADUser $username -Server $mydomain

# Retrieve information from the Organization tab of the End User.
$endUserInfo = Get-ADUser -Identity $endUser -Properties Title, Department, Manager, EmailAddress

# Retrieve the Manager's Name.
$managerDN = $endUserInfo.Manager
$manager = Get-ADUser -Identity $managerDN -Properties Name

# Display the retrieved End User information.
Write-Host "_________________________________________________________"
Write-Host "   " 
Write-Host "   " 
Write-Host "End User"
Write-Host "_________________________________________________________"
Write-Host "   " 
Write-Host " End User's Information: " -ForegroundColor Black -BackgroundColor White
Write-Host " User: $($endUserInfo.SamAccountName) " -ForegroundColor Black -BackgroundColor Yellow
Write-Host " Name: $($endUserInfo.Name) " -ForegroundColor Black -BackgroundColor Yellow
Write-Host " Email: $($endUserInfo.EmailAddress) " -ForegroundColor Black -BackgroundColor Yellow
Write-Host "  Job Title: $($endUserInfo.Title) " -BackgroundColor Cyan -ForegroundColor Black
Write-Host "  Department: $($endUserInfo.Department) " -BackgroundColor Cyan -ForegroundColor Black
Write-Host "  Manager: $($manager.Name) " -BackgroundColor Cyan -ForegroundColor Black
Write-Host "   "  
Write-Host "   "  

# Search for potential Mirrors (matching Organization tab details).
$potentialMirrorUsers = Get-ADUser -Filter {
    SamAccountName -ne $endUserInfo.SamAccountName -and
    Title -eq $endUserInfo.Title -and
    Department -eq $endUserInfo.Department -and
    Manager -eq $managerDN
} -Properties Title, Department, Manager, EmailAddress

# Initialize the mirror counter.
$mirrorCounter = 1 

# Write out the header for the mirror section.
Write-Host "   " 
Write-Host "Mirror"
Write-Host "_________________________________________________________"
Write-Host "   " 

# Display mirror results.
if ($potentialMirrorUsers) {
    foreach ($mirrorUser in $potentialMirrorUsers) {

        # Retrieve the Mirror's Manager's user object.
        $mirrorManagerDN = $mirrorUser.Manager
        $mirrorManager = Get-ADUser -Identity $mirrorManagerDN -Properties Name

        # Print out the Mirror's information.
        Write-Host " Mirror: " -ForegroundColor Black -BackgroundColor White
        Write-Host " Username: $($mirrorUser.SamAccountName) " -ForegroundColor Black -BackgroundColor Yellow
        Write-Host " Name: $($mirrorUser.Name) " -ForegroundColor Black -BackgroundColor Yellow
        Write-Host " Email: $($mirrorUser.EmailAddress) " -ForegroundColor Black -BackgroundColor Yellow
        Write-Host "  Job Title: $($mirrorUser.Title) " -BackgroundColor Cyan -ForegroundColor Black
        Write-Host "  Department: $($mirrorUser.Department) " -BackgroundColor Cyan -ForegroundColor Black
        Write-Host "  Manager: $($mirrorManager.Name) " -BackgroundColor Cyan -ForegroundColor Black
        Write-Host "   "  


        # Retrieve the Mirror's Username.
        $mirrorusername = $mirrorUser.SamAccountName

        # Increment the mirror counter.
        $mirrorCounter++

        # Exit the loop if 1 potential mirror user has been found.
        if ($mirrorCounter -eq 2) {
            break  # Exit the loop.
        }
    }
} 
    # Let the user know there are no mirrors.
    else {
        Write-Host " No potential mirror users found with matching Organization Tab details. " -ForegroundColor Black -BackgroundColor White
}

#Space 
Write-Host " "
Write-Host " "

# Input the Mirror and Enduser's username and fill in the correct server.
$Mirror = Get-ADUser $mirrorUsername -Server $mydomain
$EndUser = Get-ADUser $username -Server $mydomain

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
