[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [Security.SecureString]$InitialPassword
)

Import-Module ActiveDirectory

$domainDn = 'DC=apexdynamics,DC=internal'

$users = @(
    [pscustomobject]@{ GivenName = 'Sarah';   Surname = 'Beckett'; Sam = 'sarah.beckett';   Department = 'Executive';   Group = 'GG-Executive' }
    [pscustomobject]@{ GivenName = 'Emma';    Surname = 'Hollis';  Sam = 'emma.hollis';     Department = 'HR';          Group = 'GG-HR' }
    [pscustomobject]@{ GivenName = 'Daniel';  Surname = 'Reeves';  Sam = 'daniel.reeves';   Department = 'HR';          Group = 'GG-HR' }
    [pscustomobject]@{ GivenName = 'Thomas';  Surname = 'Clarke';  Sam = 'thomas.clarke';   Department = 'Finance';     Group = 'GG-Finance' }
    [pscustomobject]@{ GivenName = 'Olivia';  Surname = 'Grant';   Sam = 'olivia.grant';    Department = 'Sales';       Group = 'GG-Sales' }
    [pscustomobject]@{ GivenName = 'Marcus';  Surname = 'Webb';    Sam = 'marcus.webb';     Department = 'Sales';       Group = 'GG-Sales' }
    [pscustomobject]@{ GivenName = 'Chloe';   Surname = 'Dunn';    Sam = 'chloe.dunn';      Department = 'Sales';       Group = 'GG-Sales' }
    [pscustomobject]@{ GivenName = 'Raj';     Surname = 'Patel';   Sam = 'raj.patel';       Department = 'Development'; Group = 'GG-Development' }
    [pscustomobject]@{ GivenName = 'Hannah';  Surname = 'Lowe';    Sam = 'hannah.lowe';     Department = 'Development'; Group = 'GG-Development' }
    [pscustomobject]@{ GivenName = 'George';  Surname = 'Ellis';   Sam = 'george.ellis';    Department = 'Development'; Group = 'GG-Development' }
    [pscustomobject]@{ GivenName = 'Natalie'; Surname = 'Frost';   Sam = 'natalie.frost';   Department = 'IT';          Group = 'GG-IT' }
    [pscustomobject]@{ GivenName = 'Liam';    Surname = 'Hayes';   Sam = 'liam.hayes';      Department = 'Security';    Group = 'GG-Security' }
    [pscustomobject]@{ GivenName = 'Aisha';   Surname = 'Rahman';  Sam = 'aisha.rahman';    Department = 'Security';    Group = 'GG-Security' }
)

foreach ($user in $users) {
    $path = "OU=$($user.Department),OU=Users,OU=Apex,$domainDn"
    $existingUser = Get-ADUser -Filter "SamAccountName -eq '$($user.Sam)'" -ErrorAction SilentlyContinue

    if (-not $existingUser) {
        New-ADUser `
            -Name "$($user.GivenName) $($user.Surname)" `
            -GivenName $user.GivenName `
            -Surname $user.Surname `
            -DisplayName "$($user.GivenName) $($user.Surname)" `
            -SamAccountName $user.Sam `
            -UserPrincipalName "$($user.Sam)@apexdynamics.internal" `
            -Department $user.Department `
            -Path $path `
            -AccountPassword $InitialPassword `
            -ChangePasswordAtLogon $true `
            -Enabled $true
    }

    $isMember = Get-ADGroupMember -Identity $user.Group |
        Where-Object SamAccountName -eq $user.Sam

    if (-not $isMember) {
        Add-ADGroupMember -Identity $user.Group -Members $user.Sam
    }
}
