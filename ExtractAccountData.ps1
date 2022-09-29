// Generate a user report from active directory
// https://imamba.com zs1rcm


$domain_controllers = Get-ADDomainController -filter * | Select-Object name


$accounts = @{}

$flags = @{
    512 =  "NORMAL_ACCOUNT"
    514 = "ACCOUNT_DISABLE_NORMAL_ACCESSS"
    544 = "NORMAL_ACCOUNT_PASSWORD_NOT_REQUIRED"
    546 = "ACCOUNT_DISABLED_NORMAL_ACCOUNT_PASSWORD_NOT_REQUIRED"
    66048 = "NORMAL_ACCOUNT_DONT_EXPIRE_PASSWORD"
    66050 = "ACCOUNT_DISABLED_NORMAL_ACCOUNT_DONT_EXPIRE_PASSOWRD"
    66080 = "PASSOWRD_NOT_REQUIRED_NORMAL_ACCOUNT_DONT_EXPIRE_PASSWORD"
    590336 = "NORMAL_ACCOUNT_DONT_EXPIRE_PASSWORD_TRUSTED_FOR_DELEGATION"

}


$domain_controllers | foreach-Object{

    $server = $_."name"

   Write-Host "Checking DC: $server"




    $AD_data = Get-ADUser -server $server -Filter * -Properties lastLogonDate, pwdLastSet, accountExpires, whenCreated, userAccountControl | Select samaccountname,DistinguishedName,whenCreated,lastLogonDate,pwdLastSet, Passwordneverexpires, accountExpires, userAccountControl, Enabled



    foreach ($item in $AD_data){
	


	
	if($accounts.ContainsKey($item.samaccountname)){

		 	
	if($item.DistinguishedName){                               

	    $accounts[$item.samaccountname].DistinguishedName  = $item.DistinguishedName



	
	}

	if($item.whenCreated){
		$accounts[$item.samaccountname].whenCreated = $item.whenCreated
	}
	if($item.lastLogondate){
		$accounts[$item.samaccountname].lastLogondate = $item.lastLogondate
	}

	if($item.pwdLastSet){
		$hpasswordlastset = [datetime]::FromFileTime($item.pwdLastset).ToString('g')
		$accounts[$item.samaccountname].pwdLastSet = $hpasswordlastset
		#Write-Host $hpasswordlastset
		
	}

	if($item.accountExpires){
        try{
		$haccountexpires = [datetime]::FromFileTime($item.accountExpires).ToString('g')
        }
        catch{
            $haccountexpires = "Never";
            #Write-Host "error for accountExpires for account: $item.samaccountname"
        }
		$accounts[$item.samaccountname].accountExpires = $haccountexpires
		
		
	}

    if($item.userAccountControl){
        
		$accounts[$item.samaccountname].userAccountControl = $item.userAccountControl
		
		
	}

	if($item.Enabled){
		#Write-Host 'Setting Enabled'
		$accounts[$item.samaccountname].Enabled = $item.Enabled
		
	}
	


	}
	else{
		$accounts[$item.samaccountname] = @{
		DistinguishedName = $item.DistinguishedName
		whenCreated = ''
		lastLogondate = ''
		pwdLastSet = ''
		accountExpires = ''
        userAccountControl = ''
		Enabled = ''
		}


	if($item.DistinguishedName){	

	$dn = $($accounts.Item($item.samaccountname).DistinguishedName)
	$accounts[$item.samaccountname].DistinguishedName = $dn;
	

	}

	if($item.whenCreated){
		$whenCreated = $($accounts.Item($item.samaccountname).whenCreated)
		$accounts[$item.samaccountname].whenCreated = $whenCreated
	}
	if($item.lastLogondate){
		$lastLogondate = $($accounts.Item($item.samaccountname).lastlLogondate)
		$accounts[$item.samaccountname].lastLogondate = $lastLogondate
	}

	if($item.pwdLastSet){
		$passwordlastset = $($accounts.Item($item.samaccountname).pwdLastSet)
		$hpasswordlastset = [datetime]::FromFileTime($passwordlastset).ToString('g')
		$accounts[$item.samaccountname].pwdLastSet = $hpasswordlastset

	
		
	}

	if($item.accountExpires){
		$accountExpires = $($accounts.Item($item.samaccountname).accountExpires)
		try{
			$haccountExpires = [datetime]::FromFileTime($accountExpires).ToString('g')
		}
		catch{

			$haccountExpires = 'Never'

		}
		
		$accounts[$item.samaccountname].accountExpires = $haccountExpires
	
		
	}
    
    if($($accounts.Item($item.samaccountname).userAccountControl)){

        $userAccountControl =  $($accounts.Item($item.samaccountname).userAccountControl)
        
		$accounts[$item.samaccountname].userAccountControl = $userAccountControl
		
		
	}

	if($($accounts.Item($item.samaccountname).Enabled)){
		#Write-Host 'Setting Enabled'
		$Enabled = $($accounts.Item($item.samaccountname).Enabled)
		$accounts[$item.samaccountname].Enabled = $Enabled


	}
	
		

	}
	
	






    }
    
    	
}


##Write Data to CSV

$timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
$log_file = ".\ad_log-$timestamp.csv"

Add-Content -Path $log_file -Value "`"samaccountname`"; `"DistiguishedName`"; `"whenCreated`"; `"lastLogonDate`"; `"pwdLastSet`"; `"accountExpires`"; `"userAccountControl`";`"Lookup`" ;`"Enabled`""
##Write out CSV Manualy
foreach ($h in $accounts.Keys){
                 

		$DistinguishedName =  $($accounts.Item($h).DistinguishedName)
		$whenCreated =  $($accounts.Item($h).whenCreated)
		$lastLogondate =  $($accounts.Item($h).lastLogonDate)
		$pwdLastSet =  $($accounts.Item($h).pwdLastSet)
		$accountExpires =  $($accounts.Item($h).accountExpires)
        $userAccountControl = $($accounts.Item($h).userAccountControl)
		$Enabled =  $($accounts.Item($h).Enabled)

		$LOOKUP = $flags.Item($userAccountControl)

		$samaccountname = $h;

		Add-Content -Path $log_file -Value "`"$samaccountname`"; `"$DistinguishedName`"; `"$whenCreated`"; `"$lastLogonDate`"; `"$pwdLastSet`"; `"$accountExpires`";`"$userAccountControl`";`"$LOOKUP`";`"$Enabled`""


}
