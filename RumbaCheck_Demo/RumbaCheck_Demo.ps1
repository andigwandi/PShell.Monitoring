# ==========================================================================
#
# Script Name: RumbaCheck_Demo.ps1
#
# Author: Ashutosh Kumar
# Date Created: 17/12/2012
# 
# Helping URLs: http://www.experts-exchange.com/Programming/Languages/Scripting/Q_26703970.html
# 
#=========================================================================


. D:\Pegasus\PShell\RumbaCheck_Demo\Master.ps1
function RumbaCheck 
( 
        [Xml] $soap, 
        [String]$URL,
        [string]$ContentType,
        [string]$Header1,
        [string]$Header2,
        [string]$outputfile
) 
{ 
       
               
          #Executing the rumba check point code
		$Error >> "$ErrorFile"

        Write-Host "$URL"
        $webrequest=[system.net.WebRequest]::Create("$URL") 
        $webrequest.ContentType="$ContentType"
        $webrequest.Headers.Add("$Header1")
	    $webrequest.Headers.Add("$Header2")
        $WebRequest.Method= "POST"
        $requestStream = $WebRequest.GetRequestStream() 
        $Soap.save($requestStream) 
        $requestStream.Close()         
        $webrequest.Timeout=30000
        $response = $WebRequest.GetResponse() 
        $response >> $outputfile
        $responseStream = $response.GetResponseStream()
        $soapReader = [System.IO.StreamReader]($responseStream) 
        $ReturnXml = [Xml] $soapReader.ReadToEnd() 
        $responseStream.Close()         
        $status= $response.StatusCode
        return $ReturnXml 
     }
    

       
  function Rumba_DemoCheck{
   #Remove the *.Response file if Exists
       if($FileExists)
       {
       Remove-Item "$responsefilelocation"
       } 
     # Rumba check starts from here
     $startTime =[System.datetime]::now.second 
     #Calling Function RumbaCheck with different Parameters
     RumbaCheck   -soap $soap_GetLicenseProduct -URL $GetLicenseProducturl -ContentType $ContentType -Header1 "charset:utf-8" -Header2 "action:GetLicensedProduct" -outputfile $GetLicenseProduct
     RumbaCheck   -soap $soap_Authorization -URL $Authorizationurl -ContentType $ContentType -Header1 "charset:utf-8" -Header2 "action:Authorization" -outputfile $Authorization
      RumbaCheck   -soap $soap_OrganizationLifeCycle -URL $OrganizationLifeCycleurl -ContentType $ContentType -Header1 "charset:utf-8" -Header2 "action:1" -outputfile $OrganizationLifeCycle
	 RumbaCheck   -soap $soap_UserLifeCycle -URL $UserLifeCycleurl -ContentType $ContentType -Header1 "charset:utf-8" -Header2 "action:GetUser" -outputfile $UserLifeCycle
     $endTime = [System.datetime]::now.second
     $TimeDifference = $endTime-$startTime
    #Matching the patter "StatusCode" in *.response file        
      $StatusCode=Select-String $responsefilelocation -pattern "StatusCode" 
     # Sending status mail 
     if($TimeDifference -gt 30)
         {
         $Subject = “RumbaMonitoring | Rumba Demo is slow | TimeConsumed : $TimeDifference sec”
         $Body = “$StatusCode”
         #$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
		 Send-MailMessage -from $EmailFrom -to $EmailTo -subject $Subject -body $Body -smtpServer $SMTPServer 
         }
     else
         {
         $Subject = “RumbaMonitoring | Rumba Demo is successful | TimeConsumed : $TimeDifference sec”
         $Body = “$StatusCode”
         #$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
		 Send-MailMessage -from $EmailFrom -to $EmailTo -subject $Subject -body $Body -smtpServer $SMTPServer 
         }          
}
