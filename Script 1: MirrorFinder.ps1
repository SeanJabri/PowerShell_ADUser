###   PRESS RUN
###   You will be prompted for all the necessary information.



# Asks the script user to enter the End User's username and domain.
Write-Host " "
Write-Host " Enter the Username of your End User. " -ForegroundColor Black -BackgroundColor White
Write-Host " "
$username = Read-Host -Prompt "  End User's Username"
Write-Host " "
Write-Host " Enter the Domain of your End User. " -ForegroundColor Black -BackgroundColor White
Write-Host " Example: [Insert Examples]"
Write-Host " "
$mydomain = Read-Host -Prompt "  Domain"

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
Write-Host "Mirror(s)"
Write-Host "_________________________________________________________"
Write-Host "   " 

# Display mirror results.
if ($potentialMirrorUsers) {
    foreach ($mirrorUser in $potentialMirrorUsers) {

        # Retrieve the mirror's manager's user object.
        $mirrorManagerDN = $mirrorUser.Manager
        $mirrorManager = Get-ADUser -Identity $mirrorManagerDN -Properties Name

        # Print out the Mirror's information.
        Write-Host " Potential Mirror Number $($mirrorCounter): " -ForegroundColor Black -BackgroundColor White
        Write-Host " Username: $($mirrorUser.SamAccountName) " -ForegroundColor Black -BackgroundColor Yellow
        Write-Host " Name: $($mirrorUser.Name) " -ForegroundColor Black -BackgroundColor Yellow
        Write-Host " Email: $($mirrorUser.EmailAddress) " -ForegroundColor Black -BackgroundColor Yellow
        Write-Host "  Job Title: $($mirrorUser.Title) " -BackgroundColor Cyan -ForegroundColor Black
        Write-Host "  Department: $($mirrorUser.Department) " -BackgroundColor Cyan -ForegroundColor Black
        Write-Host "  Manager: $($mirrorManager.Name) " -BackgroundColor Cyan -ForegroundColor Black
        Write-Host "   "  

        # Increment the mirror counter.
        $mirrorCounter++

        # Exit the loop if 5 potential mirror users have been found.
        if ($mirrorCounter -eq 6) {
            Write-Host "**There may be more mirrors, but this script stops after finding 5.**"
            break  # Exit the loop.
        }
    }
} 
    # Let the user know there are no mirrors.
    else {
        Write-Host " No potential mirror users found with matching Organization Tab details. " -ForegroundColor Black -BackgroundColor White
}
