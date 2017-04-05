# Global Variables needed for this scripts
[String[]]$MYMAIL="pegasusre@excelindia.com"
$REMAIL="pegasusre@excelindia.com"
$MAXUNZIPPEDSIZE=200
$SUMMARYDIR="\\pegasus29\Logs\ErrorSummary"
$PSFunctionLib="D:\Pegasus\PShell\PSHelperLib\PSHelperLibrary.ps1"
$FileName="ErrorSummary.html"

Function ErrorSummary(
	[String] $Site,
	[String] $HostName, 
	[String] $HostNumber,
	[String] $DatabaseName,
	[String] $Title,
	[string[]] $EmailTo,
	[String] $RollUpTo	
)
{
    # Removing existing XML and HTML reports
 	Remove-Item *.xml
	Remove-Item *.html
	Remove-Item *.zip
	$strHost = $HostNumber -split "," 
	foreach($HostPostfix in $strHost)
	{
		# Get the Full Host name
		$FullHostName=$HostName+$HostPostfix
	    write-host $FullHostName
		 $ServerIPaddress = [System.Net.Dns]::GetHostEntry($FullHostName).AddressList
		 Write-Host ("Server IP is: " + $ServerIPaddress)
	
		# extract events of interest from system event log
		logparser -i:EVT "SELECT TO_DATE(TimeGenerated) as date, TO_TIME(TimeGenerated) as time,EventTypeName as s-sitename, 	ComputerName,'$ServerIPaddress' as c-ip, EventID as sc-status, SourceName as cs-cookie, REPLACE_CHR(REPLACE_CHR(SUBSTR(Message,0,2000), '<', '&lt;'), '>', '&gt;') as Message INTO events.$FullHostName.xml FROM '\\$FullHostName\Application' WHERE EventType IN (1;2;16) ORDER BY date, time" -o:XML -oCodepage:1252 -iCheckpoint:events.$FullHostName.lpc >> log
 
		# extract events of interest from IIS httperr log
		logparser -i:HTTPERR "SELECT TO_DATE(TO_LOCALTIME(TO_TIMESTAMP(date, time))) as date,TO_TIME(TO_LOCALTIME(TO_TIMESTAMP(date, time))) as time,'httperr' as s-sitename,'$FullHostName' as ComputerName, c-ip, sc-status, s-reason as cs-cookie,		SUBSTR(REPLACE_CHR(REPLACE_CHR(STRCAT(cs-method,STRCAT(' ',cs-uri)), '<', '&lt;'), '>', '&gt;'), 0, 128) as Message INTO httperr.$FullHostName.xml FROM '\\$FullHostName\c$\windows\system32\logfiles\httperr\*.log' WHERE s-reason <> 'Timer_ConnectionIdle' AND s-reason <> 'Timer_MinBytesPerSecond' AND cs-uri not like '/Pegasus/Scripts/PngFix%'" -o:XML -oCodepage:1252 -iCheckpoint:httperr.$FullHostName.lpc >> log
		
				
		if(!($DatabaseName -eq ""))
		{
			$strDBHost = $DatabaseName -split ","
			foreach ($DBServer in $strDBHost)
			{
				echo $DBServer
				$DBServerIP = [System.Net.Dns]::GetHostEntry($DBServer).AddressList
				Write-Host ("Server IP is: " + $DBServerIP)
				
				# extract events of interest from IIS log
				logparser -i:IISW3C "SELECT date, time, 'IIS' as s-sitename,s-computername as ComputerName,c-ip,CASE sc-win32-status WHEN 0 then TO_STRING(sc-status) ELSE STRCAT(TO_STRING(sc-status),STRCAT('/',TO_STRING(sc-win32-status))) END as sc-status,COALESCE(EXTRACT_VALUE(cs(Cookie), '+ASP.NET_SessionId', ';'), '-') as cs-cookie,SUBSTR(REPLACE_CHR(REPLACE_CHR(STRCAT(cs-method,STRCAT(' ',STRCAT([cs-uri-stem],STRCAT(' ',[cs-uri-query])))), '<', '&lt;'), '>', '&gt;'), 0, 128) as Message INTO iislogerr.$DBServer.xml FROM '\\$DBServer\Application' WHERE sc-status > 399 AND cs-uri-stem not like '%/favicon.ico' AND cs-method <> 'OPTIONS' AND cs-uri-stem not like '/Pegasus/Scripts/PngFix%' OR [cs-uri-stem] LIKE '%ErrorHandler%' or cs-uri-query like '%Invalid+login+name%' or cs-uri-query like '%RumbaLogoutServiceDown%'" -o:XML -oCodepage:1252 -iCheckpoint:iislogerr.$DBServer.lpc >> log
				
				# extract events of interest from database system event log
				logparser -i:EVT "SELECT TO_DATE(TimeGenerated) as date,TO_TIME(TimeGenerated) as time,EventTypeName as s-sitename,ComputerName,'$IP' as c-ip, EventID as sc-status,SourceName as cs-cookie,SUBSTR(Message,0,2000) as Message INTO events.$DBServerIP.xml FROM '\\\\$DBServerIP\Application' WHERE EventType IN (1;2;16) ORDER BY date, time" -o:XML -oCodepage:1252 -iCheckpoint:events.$DBServer.lpc >> log
			}
		}
	}
	
	# Delete Empty XML files
	#Get-ChildItem -filter "*.xml" | where {$_.length -eq 0 } | Remove-Item

	# merge extracted events into html report
	logparser -i:XML "SELECT DISTINCT count(*) as hits,COALESCE(TO_STRING(sc-status),cs-cookie) as status,substr([Message],0,1600) as Message INTO rollupreport.html FROM '*.xml' GROUP BY status,Message ORDER BY hits DESC" -o:TPL -tpl:.\rollupsummary.tpl -e:100 >> log
	
	
	logparser -i:XML "SELECT date,time,s-sitename,TO_LOWERCASE(ComputerName) as ComputerName,c-ip,sc-status,cs-cookie,substr([Message],0,1600) as Message into report.html FROM '*.xml' ORDER By date, time, s-sitename" -o:TPL -tpl:.\errorsummary.tpl -stats:OFF -e:100
	
	
	#Calling ZIP Function
	. $PSFunctionLib
	Zip -FileToZip *.html -ZipFile $FileName
		
	#Calling Copy Function
	. $PSFunctionLib
	CopyToSummary -Site $Site -FileName $FileName -SUMMARYDIR $SUMMARYDIR
	#Start-Sleep -s 10
	#Test if report.html exist and size cann't be zero then send a file
	if(Test-Path report.html)
	{
		[int] $Size = (Get-Item report.html).Length
		write-host $Size
		if($Size -gt 0)
		{
			echo "Sending Email..."
			SendZipMail -Subject ($Title + " - Detailed") -EmailTo  $EmailTo -RollUpTo "" -File "$(get-location)\report.html"
		}
	}
	#Test if rollupreport.html exist and size cann't be zero then send a file
   if(Test-Path rollupreport.html)
	 {
		[int] $Size = (Get-Item rollupreport.html).Length
		write-host $Size
		if($Size -gt 0)
		{
			echo "Sending rEmail..."
			SendZipMail -Subject ($Title + " - Summary") -EmailTo  $EmailTo -RollUpTo "" -File "$(get-location)\rollupreport.html"
		}
	 }
	
	echo "error summary done at Date" >> log	
}


#Checking the size of files that it must not be maximum unzipped file size and then send to the mentioned id's.
function SendZipMail([String] $Subject,[string[]] $EmailTo,[String] $RollUpTo,[String] $File)
{
	[int] $Size = (Get-Item $File).Length/1KB
	if ($Size -gt $MAXUNZIPPEDSIZE)
	{
		$Zip_FileName=split-path -Leaf $File
	    . $PSFunctionLib
		Zip -FileToZip $File -ZipFile $Zip_FileName
		echo "zipped function call"
		Send-MailMessage -from "dontreply@pearsoncmg.com" -to $EmailTo -subject $Subject -body "Email From Error Summary Script" -smtpServer "mailhost.pearsoncmg.com" -Attachment "$(get-location)\$Zip_FileName.zip"
		#Remove-Item $Zip_FileName.zip
	}
	else
	{
		echo "unzipped function call"
		Send-MailMessage -from "dontreply@pearsoncmg.com" -to $EmailTo -subject $Subject -body "Email From Error Summary Script" -smtpServer "mailhost.pearsoncmg.com" -Attachment $File 
	}
  Start-Sleep -s 10
}

ErrorSummary -Site SCHOOL -HostName PEGFEQAV -HostNumber "12,13" -DatabaseName "" -Title "5.15 School VM Error summary" -EmailTo $MYMAIL -RollUpTo ""
ErrorSummary -Site HEDVM -HostName PEGFEQAV -HostNumber "17,18" -DatabaseName "" -Title "5.15 HED VM Error summary" -EmailTo $MYMAIL -RollUpTo ""
#SendZipMail -Subject $Title -EmailTo  $EmailTo -RollUpTo "" -File "D:\Pegasus\PShell\ErrorSummaryReport\rollupreport.html"
#ErrorSummary -Site HEDVM -HostName PEGFEQAV -HostNumber "10,11" -DatabaseName "" -Title "[Powershell] 5.11 HED VM Error summary" -EmailTo $MYMAIL -RollUpTo ""

