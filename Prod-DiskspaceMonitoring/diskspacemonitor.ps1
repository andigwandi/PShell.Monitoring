
Param ( 
$K12computers = (Get-Content  "Schoollist.txt"), 
$HEDcomputers = (Get-Content  "HEDlist.txt"), 
$MILcomputers = (Get-Content  "MILlist.txt"), 
$COREcomputers = (Get-Content  "CORElist.txt"), 
$GITcomputers = (Get-Content  "GIT_SIM5list.txt")
) 
Start-Transcript -Path "Temp.log"
$Title1="School Hard Drive Report to HTML" 
$Title2="HED Hard Drive Report to HTML" 
$Title3="MIL Hard Drive Report to HTML" 
$Title4="CORE Hard Drive Report to HTML" 
$Title5="GradeIT, SIMDL, SIM5 Hard Drive Report to HTML" 
 
#embed a stylesheet in the html header 
$head = @" 
<mce:style><!-- 
mce:0 
--></mce:style><style _mce_bogus="1"><!-- 
mce:0 
--></style> 
<Title>$Title</Title> 
<br> 
"@  
 
#define an array for html fragments 
$K12fragments=@() 
$HEDfragments=@()
$MILfragments=@() 
$COREfragments=@()
$GITfragments=@()
 
#get the drive data 
$K12data=Get-WmiObject -Class Win32_logicaldisk -filter "drivetype=3" -computer $K12computers 
$HEDdata=Get-WmiObject -Class Win32_logicaldisk -filter "drivetype=3" -computer $HEDcomputers
$MILdata=Get-WmiObject -Class Win32_logicaldisk -filter "drivetype=3" -computer $MILcomputers 
$COREdata=Get-WmiObject -Class Win32_logicaldisk -filter "drivetype=3" -computer $COREcomputers 
$GITdata=Get-WmiObject -Class Win32_logicaldisk -filter "drivetype=3" -computer $GITcomputers  
 
#group data by computername 
$K12groups=$K12Data | Group-Object -Property SystemName
$HEDgroups=$HEDData | Group-Object -Property SystemName  
$MILgroups=$MILData | Group-Object -Property SystemName
$COREgroups=$COREData | Group-Object -Property SystemName 
$GITgroups=$GITData | Group-Object -Property SystemName 
 
#this is the graph character 
[string]$g=[char]9608  
 
#create html fragments for each computer 
#iterate through each group object 
         
ForEach ($computer in $K12groups) { 
     
    $K12fragments+="<H2>$($computer.Name)</H2>" 
     
    #define a collection of drives from the group object 
    $Drives=$computer.group 
    Write-Host $computer
	
    Write-Host "create an html fragment "
    $html=$drives | Select @{Name="Drive";Expression={$_.DeviceID}}, 
    @{Name="SizeGB";Expression={$_.Size/1GB  -as [int]}}, 
    @{Name="UsedGB";Expression={"{0:N2}" -f (($_.Size - $_.Freespace)/1GB) }}, 
    @{Name="FreeGB";Expression={"{0:N2}" -f ($_.FreeSpace/1GB) }}, 
    @{Name="Usage";Expression={ 
      $UsedPer= (($_.Size - $_.Freespace)/$_.Size)*100 
      $UsedGraph=$g * ($UsedPer/2) 
      $FreeGraph=$g* ((100-$UsedPer)/2) 
      #I'm using place holders for the < and > characters 
      "xopenFont color=Redxclose{0}xopen/FontxclosexopenFont Color=Yellowxclose{1}xopen/fontxclose" -f $usedGraph,$FreeGraph 
    }} | ConvertTo-Html -Fragment  
     
    Write-Host "replacing the tag place holders."
    $html=$html -replace "xopen","<" 
    $html=$html -replace "xclose",">" 
     
    #add to fragments 
    $K12Fragments+=$html 
     
    #insert a return between each computer 
    $K12fragments+="<br>" 
     
} #foreach computer 

ForEach ($computer in $HEDgroups) { 
     
    $HEDfragments+="<H2>$($computer.Name)</H2>" 
     
    #define a collection of drives from the group object 
    $Drives=$computer.group 
    Write-Host $computer
	
    Write-Host "create an html fragment "
    $html=$drives | Select @{Name="Drive";Expression={$_.DeviceID}}, 
    @{Name="SizeGB";Expression={$_.Size/1GB  -as [int]}}, 
    @{Name="UsedGB";Expression={"{0:N2}" -f (($_.Size - $_.Freespace)/1GB) }}, 
    @{Name="FreeGB";Expression={"{0:N2}" -f ($_.FreeSpace/1GB) }}, 
    @{Name="Usage";Expression={ 
      $UsedPer= (($_.Size - $_.Freespace)/$_.Size)*100 
      $UsedGraph=$g * ($UsedPer/2) 
      $FreeGraph=$g* ((100-$UsedPer)/2) 
      #I'm using place holders for the < and > characters 
      "xopenFont color=Redxclose{0}xopen/FontxclosexopenFont Color=Yellowxclose{1}xopen/fontxclose" -f $usedGraph,$FreeGraph 
    }} | ConvertTo-Html -Fragment  
     
    Write-Host "replacing the tag place holders."
    $html=$html -replace "xopen","<" 
    $html=$html -replace "xclose",">" 
     
    #add to fragments 
    $HEDFragments+=$html 
     
    #insert a return between each computer 
    $HEDfragments+="<br>" 
     
}

ForEach ($computer in $MILgroups) { 
     
    $MILfragments+="<H2>$($computer.Name)</H2>" 
     
    #define a collection of drives from the group object 
    $Drives=$computer.group 
    Write-Host $computer
	
    Write-Host "create an html fragment "
    $html=$drives | Select @{Name="Drive";Expression={$_.DeviceID}}, 
    @{Name="SizeGB";Expression={$_.Size/1GB  -as [int]}}, 
    @{Name="UsedGB";Expression={"{0:N2}" -f (($_.Size - $_.Freespace)/1GB) }}, 
    @{Name="FreeGB";Expression={"{0:N2}" -f ($_.FreeSpace/1GB) }}, 
    @{Name="Usage";Expression={ 
      $UsedPer= (($_.Size - $_.Freespace)/$_.Size)*100 
      $UsedGraph=$g * ($UsedPer/2) 
      $FreeGraph=$g* ((100-$UsedPer)/2) 
      #I'm using place holders for the < and > characters 
      "xopenFont color=Redxclose{0}xopen/FontxclosexopenFont Color=Yellowxclose{1}xopen/fontxclose" -f $usedGraph,$FreeGraph 
    }} | ConvertTo-Html -Fragment  
     
    Write-Host "replacing the tag place holders."
    $html=$html -replace "xopen","<" 
    $html=$html -replace "xclose",">" 
     
    #add to fragments 
    $MILFragments+=$html 
     
    #insert a return between each computer 
    $MILfragments+="<br>" 
     
} 

ForEach ($computer in $COREgroups) { 
     
    $COREfragments+="<H2>$($computer.Name)</H2>" 
     
    #define a collection of drives from the group object 
    $Drives=$computer.group 
    Write-Host $computer
	
    Write-Host "create an html fragment "
    $html=$drives | Select @{Name="Drive";Expression={$_.DeviceID}}, 
    @{Name="SizeGB";Expression={$_.Size/1GB  -as [int]}}, 
    @{Name="UsedGB";Expression={"{0:N2}" -f (($_.Size - $_.Freespace)/1GB) }}, 
    @{Name="FreeGB";Expression={"{0:N2}" -f ($_.FreeSpace/1GB) }}, 
    @{Name="Usage";Expression={ 
      $UsedPer= (($_.Size - $_.Freespace)/$_.Size)*100 
      $UsedGraph=$g * ($UsedPer/2) 
      $FreeGraph=$g* ((100-$UsedPer)/2) 
      #I'm using place holders for the < and > characters 
      "xopenFont color=Redxclose{0}xopen/FontxclosexopenFont Color=Yellowxclose{1}xopen/fontxclose" -f $usedGraph,$FreeGraph 
    }} | ConvertTo-Html -Fragment  
     
    Write-Host "replacing the tag place holders."
    $html=$html -replace "xopen","<" 
    $html=$html -replace "xclose",">" 
     
    #add to fragments 
    $COREFragments+=$html 
     
    #insert a return between each computer 
    $COREfragments+="<br>" 
     
}

ForEach ($computer in $GITgroups) { 
     
    $GITfragments+="<H2>$($computer.Name)</H2>" 
     
    #define a collection of drives from the group object 
    $Drives=$computer.group 
    Write-Host $computer
	
    Write-Host "create an html fragment "
    $html=$drives | Select @{Name="Drive";Expression={$_.DeviceID}}, 
    @{Name="SizeGB";Expression={$_.Size/1GB  -as [int]}}, 
    @{Name="UsedGB";Expression={"{0:N2}" -f (($_.Size - $_.Freespace)/1GB) }}, 
    @{Name="FreeGB";Expression={"{0:N2}" -f ($_.FreeSpace/1GB) }}, 
    @{Name="Usage";Expression={ 
      $UsedPer= (($_.Size - $_.Freespace)/$_.Size)*100 
      $UsedGraph=$g * ($UsedPer/2) 
      $FreeGraph=$g* ((100-$UsedPer)/2) 
      #I'm using place holders for the < and > characters 
      "xopenFont color=Redxclose{0}xopen/FontxclosexopenFont Color=Yellowxclose{1}xopen/fontxclose" -f $usedGraph,$FreeGraph 
    }} | ConvertTo-Html -Fragment  
     
    Write-Host "replacing the tag place holders."
    $html=$html -replace "xopen","<" 
    $html=$html -replace "xclose",">" 
     
    #add to fragments 
    $GITFragments+=$html 
     
    #insert a return between each computer 
    $GITfragments+="<br>" 
     
}

Function sendEmail 
{ param($from,$to,$subject,$smtphost,$htmlFileName) 

Write-Host "Sending Email"
$body = Get-Content $htmlFileName 
$smtp= New-Object System.Net.Mail.SmtpClient $smtphost 
$msg = New-Object System.Net.Mail.MailMessage $from, $to, $subject, $body 
$msg.isBodyhtml = $true 
$smtp.send($msg) 
 
} 
 
#add a footer 
$footer=("<br><I>Report run {0} by {1}\{2}<I>" -f (Get-Date -displayhint date),$env:userdomain,$env:username) 
$K12fragments+=$footer
$HEDfragments+=$footer
$MILfragments+=$footer
$COREfragments+=$footer
$GITfragments+=$footer

 
#write the result to a file 
ConvertTo-Html -head $head -body $K12fragments  | Out-File .\K12drivereport.htm
ConvertTo-Html -head $head -body $HEDfragments  | Out-File .\HEDdrivereport.htm
ConvertTo-Html -head $head -body $MILfragments  | Out-File .\MILdrivereport.htm
ConvertTo-Html -head $head -body $COREfragments  | Out-File .\COREdrivereport.htm
ConvertTo-Html -head $head -body $GITfragments  | Out-File .\GITdrivereport.htm
 
$date = Get-Date -format G
sendEmail "dontreply@pearsoncmg.com" "pegasusre@excelindia.com" "Prod School- Disk Space Report - $date" "mailhost.pearsoncmg.com" K12drivereport.htm
sendEmail "dontreply@pearsoncmg.com" "pegasusre@excelindia.com" "Prod Mylabs- Disk Space Report - $date" "mailhost.pearsoncmg.com" HEDdrivereport.htm
sendEmail "dontreply@pearsoncmg.com" "pegasusre@excelindia.com" "Prod MIL- Disk Space Report - $date" "mailhost.pearsoncmg.com" MILdrivereport.htm
sendEmail "dontreply@pearsoncmg.com" "pegasusre@excelindia.com" "Prod CORE- Disk Space Report - $date" "mailhost.pearsoncmg.com" COREdrivereport.htm
sendEmail "dontreply@pearsoncmg.com" "pegasusre@excelindia.com" "Prod GradeIT, SIMDL and SIM5- Disk Space Report - $date" "mailhost.pearsoncmg.com" GITdrivereport.htm