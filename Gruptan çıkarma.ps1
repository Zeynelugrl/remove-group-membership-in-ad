$OU_Dizini = Read-Host -Prompt 'OU içeriğini yazınız Örnek: "OU=TestUsers,DC=zeynelugurlu,DC=com"'
$CSV_Dizini = Read-Host -Prompt 'CSV Export etmek istediğiniz dizini seçiniz. Örnek:C:\Users\zeynel.ugurlu\Desktop'
$GrupAdı = Read-Host -Prompt 'Eklemek istediğiniz grup adını olduğu gibi yazınız.'
 
 
 Get-ADUser -Filter * -SearchBase $OU_Dizini -Properties * | Select-Object UserPrincipalName | export-csv -path $CSV_Dizini\RemoveGruop.csv

# Import AD Module
Import-Module ActiveDirectory

# CSV formatındaki veriyi içeri al.
$Users = Import-Csv $CSV_Dizini\RemoveGruop.csv"

# Kullanıcıların hangi gruptan çıkarılacağını seçin.
$Group = $GrupAdı

foreach ($User in $Users) {
    #  UPN değerini al
    $UPN = $User.UserPrincipalName

    # UPN değeri ile SamAccountName'i eşle.
    $ADUser = Get-ADUser -Filter "UserPrincipalName -eq '$UPN'" 
    
    # Kullanıcı bulunamadıysa
    if (-not $ADUser) {
        Write-Host "$UPN does not exist in AD" -ForegroundColor Red
    }
    else {
        # Kullanıcının üyeliğini geri al
        $ExistingGroups = Get-ADPrincipalGroupMembership $ADUser.SamAccountName 

        # User member of group
        if ($ExistingGroups.Name -eq $Group) {

            # Kullanıcıyı gruptan çıkar
            Remove-ADGroupMember -Identity $Group -Members $ADUser.SamAccountName -Confirm:$false 
            Write-Host "Removed $UPN from $Group" -ForeGroundColor Green
        }
        else {
            # Kullanıcı gruba üye değilse
            Write-Host "$UPN does not exist in $Group" -ForeGroundColor Yellow
        }
    }
}
