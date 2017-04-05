
Param ( 
$HEDcomputers = (Get-Content  "HEDlist.txt"), 
$GITcomputers = (Get-Content  "GIT_SIM5list.txt")
) 
Start-Transcript -Path "Temp.log"
$Title1="PPE HED Hard Drive Report to HTML" 
$Title2="PPE GradeIT and SIM5 Hard Drive Report to HTML" 
 
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
$HEDfragments=@()
$GITfragments=@()
 
#get the drive data 
$HEDdata=Get-WmiObject -Class Win32_logicaldisk -filter "drivetype=3" -computer $HEDcomputers
$GITdata=Get-WmiObject -Class Win32_logicaldisk -filter "drivetype=3" -computer $GITcomputers  
 
#group data by computername 
$HEDgroups=$HEDData | Group-Object -Property SystemName  
$GITgroups=$GITData | Group-Object -Property SystemName 
 
#this is the graph character 
[string]$g=[char]9608  
 
#create html fragments for each computer 
#iterate through each group object 
         
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
$HEDfragments+=$footer
$GITfragments+=$footer

 
#write the result to a file 
ConvertTo-Html -head $head -body $HEDfragments  | Out-File .\HEDdrivereport.htm
ConvertTo-Html -head $head -body $GITfragments  | Out-File .\GITdrivereport.htm
 
$date = Get-Date -format G
sendEmail "dontreply@pearsoncmg.com" "pegasusre@excelindia.com,pegperfindia@excelindia.com" "PPE Mylabs- Disk Space Report - $date" "mailhost.pearsoncmg.com" HEDdrivereport.htm
sendEmail "dontreply@pearsoncmg.com" "pegasusre@excelindia.com,pegperfindia@excelindia.com" "PPE GradeIT and SIM5- Disk Space Report - $date" "mailhost.pearsoncmg.com" GITdrivereport.htm