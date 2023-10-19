## Entrez un chemin d’accès vers votre fichier d’importation CSV
$ADUsers = Import-csv C:\scripts\newusers.csv

foreach ($User in $ADUsers)
{
$Username    = $User.username
$Password    = $User.password
$Firstname   = $User.firstname
$Lastname    = $User.lastname
$Department  = $User.department
$OU          = $User.ou

## Vérifiez si le compte utilisateur existe déjà dans AD
if (Get-ADUser -F {SamAccountName -eq $Username})
{
#Si l’utilisateur existe, éditez un message d’avertissement
Write-Warning "A user account $Username has already exist in Active Directory"
}
else
{
#Si un utilisateur n’existe pas, créez un nouveau compte utilisateur         
#Le compte sera créé dans I’unité d’organisation indiquée dans la variable $OU du fichier CSV
#N’oubliez pas de changer le nom de domaine dans la variable « -UserPrincipalName ».
New-ADUser `
-SamAccountName $Username `
-UserPrincipalName "$Username@yourdomain.com" `
-Name "$Firstname $Lastname" `
-GivenName $Firstname `
-Surname $Lastname `
-Enabled $True `
-ChangePasswordAtLogon $True `
-DisplayName "$Lastname, $Firstname" `
-Department $Department `
-Path $OU `
-AccountPassword (convertto-securestring $Password -AsPlainText -Force)
}
}
