# ==========================================================================
#
# Script Name: slowlogout.ps1
#
# Author: Ashutosh Kumar
# Date Created: 20/12/2012
# This script will count the number of hits using logparser query 
# and if number of hits is greater than 20 then it will send the mail
# Helping URLs: http://www.experts-exchange.com/Programming/Languages/Scripting/Q_26703970.html
#
#=========================================================================

set-alias logparser "C:\Program Files (x86)\Log Parser 2.2\LogParser.exe"
. D:\Pegasus\PShell\SlowLogout\Master.ps1
Function slowout
{
$result=Logparser $query -i:IISw3c -rtp:1 -headers:off -stats:off -e:1000
if($FileExists)
   {
   [INT]$Fileoutput=Get-Content $stdout
   }   
   Write-host "$Fileoutput"
   if($Fileoutput -gt 1)
    {
         $Subject ="Status of school.pearsoned.com is:$Fileoutput"
         $Body = "Possible problem with school.pearsoned.com: $Fileoutput logouts failed with RumbaLogoutServiceDown error in the past 15 minutes"
         #$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
		 Send-MailMessage -from $EmailFrom -to $EmailTo -subject $Subject -body $Body -smtpServer $SMTPServer
    }
  
}    

