# GEU - Get Entra User Info

A PowerShell function to quickly query and display Microsoft Entra ID (Azure AD) user information.

## Features

- Search for one or multiple users at once
- Display results in console table or GUI
- Automatically connects to Entra if needed
- Clean, resizable GUI for detailed viewing
- Fast alias: `GEU` instead of typing full command

## Installation

1. Open your PowerShell profile:
   ```powershell
   notepad $PROFILE
   ```

2. If the file doesn't exist, create it:
   ```powershell
   New-Item -Path $PROFILE -Type File -Force
   notepad $PROFILE
   ```

3. Copy and paste the entire function code into the file

4. Save and close the file

5. Reload your profile:
   ```powershell
   . $PROFILE
   ```

## Usage

### Basic Usage

Search for a single user:
```powershell
GEU sosn071
```

### Multiple Users

Search for multiple users (space-separated):
```powershell
GEU sosn071 user2 user3
```

Or comma-separated:
```powershell
GEU sosn071, user2, user3
```

### GUI Mode

Display results in a graphical window:
```powershell
GEU sosn071 -GUI
```

**Single user:** Shows detailed form with all fields  
**Multiple users:** Shows sortable/filterable grid

## Fields Displayed

The function displays the following user information:

1. **createdDateTime** - When the account was created
2. **companyName** - Company name
3. **displayName** - User's display name
4. **mail** - Email address
5. **employeeId** - Employee ID number
6. **jobTitle** - Job title
7. **department** - Department name
8. **city** - Location/city
9. **accountEnabled** - Account status (True/False)
10. **mailNickname** - Email alias
11. **userPrincipalName** - UPN (login name)

## Examples

### Example 1: Quick lookup
```powershell
GEU sosn071
```
Output: Console table with user information

### Example 2: Compare multiple users
```powershell
GEU sosn071 test user2
```
Output: Console table with all three users

### Example 3: Detailed view
```powershell
GEU sosn071 -GUI
```
Output: Windows form with all fields in a clean, scrollable layout

### Example 4: Multiple users in GUI
```powershell
GEU sosn071 test user2 -GUI
```
Output: Grid view with sortable/filterable columns

## Troubleshooting

### "Not connected to Entra"
The function will automatically connect you. Just follow the authentication prompts.

### "Could not find user: username"
The username doesn't exist in Entra or you don't have permission to view it.

### No output
Make sure you've reloaded your profile after installation:
```powershell
. $PROFILE
```

## Requirements

- PowerShell 5.1 or later
- Microsoft.Graph.Entra PowerShell module
- Appropriate permissions to read Entra user data

## Customization

### Add/Remove Fields

Edit the `$script:FieldsToShow` array in the function:

```powershell
$script:FieldsToShow = @(
    'createdDateTime'
    'companyName'
    'displayName'
    # Add more fields here
)
```

### Uncomment Hidden Fields

The function has two fields commented out that you can enable:
- `onPremisesSamAccountName`
- `onPremisesUserPrincipalName`

Just remove the `#` in front of them in the code.

## Tips

- **Maximize your console** for better table viewing
- **Use `-GUI` for long values** that get truncated in console
- **Press Ctrl+C in GUI** to copy selected text from any field
- **Resize the GUI window** - all fields adjust automatically


