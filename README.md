# PowerShell_ADUser
This repository contains PowerShell scripts designed for interacting with Active Directory Users.



## Script 1: MirrorFinder.ps1

**What it Does:**
This script takes an End User and identifies 5 potential Mirror Users with the same job title, department, and manager.

**Use Case:**
Use this script when onboarding or transferring a user, and you need to find someone with similar permissions.

**How it Works:**
1. Prompt the script user for the End User's username and domain (with input validation).
2. Compare the Organization Tab (job title, department, and manager) to identify potential mirrors.
3. Display information on up to 5 Mirrors, including canonical name, username, email address, job title, department, and manager's name.



## Script 2: MirrorGroups.ps1

**What it Does:**
This script requests the domain and two users (one as the Mirror User and one as the End User) and then copies Security, User, Admin, and Organizational groups from the Mirror User to the End User.

**Use Case:**
When adding a new user or transferring them to a different department, their group memberships need to be updated. This script copies all the Mirror User's correct groups to the End User, ensuring correct permissions. It's most effective when using a specific Mirror User.

**How it Works:**
1. Prompt the script user for the End User's username, the Mirror User's username, and their domain (with input validation).
2. Copy the Mirror User's groups.
3. Assign the copied groups to the End User.
4. List successfully added groups in green and failed additions in red.



## Script 3: FindAMirrorAndMirrorMemberOf.ps1

**What it Does:**
This script identifies 5 potential Mirror Users (users with the same job title, department, and manager) for an End User. It then prompts the user to select one of these mirrors and copies the Security, User, Admin, and Organizational groups from the selected Mirror User to the End User.

**Use Case:**
When adding a new user or transferring them to a different department, their group memberships need updating. This script copies the correct groups from a Mirror User to the End User, ensuring correct permissions. It's most effective when the Mirror User isn't specified.

**How it Works:**
1. Prompt the script user for the End User's username and domain (with input validation).
2. Compare the Organization Tab (job title, department, and manager) ) to identify potential mirrors.
3. List information on up to 5 Mirrors, including canonical name, username, email address, job title, department, and manager's name.
4. Prompt the script user to choose a Mirror User (with input validation).
5. Copy the Mirror User's groups.
6. Assign the copied groups to the End User.
7. List successfully added groups in green and failed additions in red.
