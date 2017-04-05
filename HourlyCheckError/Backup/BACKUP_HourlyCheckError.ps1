# Global Variables needed for this scripts
$REMAIL="pegasusre@excelindia.com"
[string[]]$MYMAIL="shilpi.ahuja@imfinity.com"
$ROLLUPALLMAIL="sanjeev.kumar@imfinity.com"
$PSFunctionLib="D:\Pegasus\PShell\PSHelperLib\PSHelperLibrary.ps1"
$MAXUNZIPPEDSIZE=200
$FileName="HourlyCheckError.html"

$SUMMARYDIR="\\pegasus29\Logs\HourlySummary"


function sendzipmail([String] $subject,[string[]] $users,[String] $File)
{

	[int] $Size = (Get-Item $File).Length/1KB
	if ($Size -gt $MAXUNZIPPEDSIZE)
	{
	 write-host Function_Called
		$Zip_FileName=split-path -Leaf $File
		write-host $Zip_FileName
	    . $PSFunctionLib
		Zip -FileToZip $File -ZipFile $Zip_FileName
		Send-MailMessage -from "dontreply@pearsoncmg.com" -to $users -subject $subject -body "Email from Hourly Summary Script" -smtpServer "mailhost.pearsoncmg.com" -Attachment "$(get-location)\$Zip_FileName.zip"
		#Remove-Item $File.zip
	}
	else
	{
		Send-MailMessage -from "dontreply@pearsoncmg.com" -to $users -subject $subject -body "Email from Hourly Summary Script" -smtpServer "mailhost.pearsoncmg.com" -Attachment $File
	}
  Start-Sleep -s 10
}
function HourlyErrorCheck([String] $Site,[String] $HostName,[String] $HostNumber,[String] $DatabaseName,[String] $Subject,[string[]] $EmailTo,[String] $EmailCC,[String] $IISLogFile)
{
	Write-Host Removing existing XML Files....
	Remove-Item *.xml
	Remove-Item *.html 
	Write-Host Getting the Host...
	$strHost = $HostNumber -split ","
	foreach($HostPostfix in $strHost)
	{
		
		# Get the Full Host name
		$FullHostName=$HostName+$HostPostfix
		Write-Host Generating Report for $FullHostName  ...
		# Getting the Logs path
		$LogFilePath = '\D$\Excelsoft\IISLogFiles'
		# extract events of interest from system event log
		$IP =[System.Net.Dns]::GetHostEntry($FullHostName).AddressList
		
		# extract events of interest from system event log
		$SysEventQuery="SELECT TO_DATE(TimeGenerated) as date,TO_TIME(TimeGenerated) as time,EventTypeName as s-sitename,ComputerName,'$IP' as c-ip, EventID as sc-status,SourceName as cs-cookie,SUBSTR(Message,0,2000) as Message INTO events.$FullHostName.xml FROM '\\$FullHostName\Application' WHERE EventType IN (1;2) AND ( Message LIKE '%SQL%' OR SourceName LIKE '%.NET%' ) ORDER BY date, time"
		Write-Host Generating System Event XML
		logparser -i:EVT $SysEventQuery -o:XML -oCodepage:1252 -iCheckpoint:events.$FullHostName.lpc >> log
				
		# extract events of interest from IIS httperr log
		write-host $LogFilePath
		$IISLogQuery= "SELECT TO_DATE(TO_LOCALTIME(TO_TIMESTAMP(date, time))) as date,TO_TIME(TO_LOCALTIME(TO_TIMESTAMP(date, time))) as time,'IIS' as s-sitename,s-computername as ComputerName,c-ip,CASE sc-win32-status WHEN 0 then TO_STRING(sc-status) ELSE STRCAT(TO_STRING(sc-status),STRCAT('/',TO_STRING(sc-win32-status))) END as sc-status,COALESCE(EXTRACT_VALUE(cs(Cookie), '+ASP.NET_SessionId', ';'), '-') as cs-cookie,STRCAT(cs-method,STRCAT(' ',STRCAT([cs-uri-stem],STRCAT(' ',[cs-uri-query])))) as Message INTO iislogerr.$FullHostName.xml FROM '\\$FullHostName\$LogFilePath\$IISLogFile\*.log' WHERE sc-status > 499 or [cs-uri-stem] LIKE '%SIMDATAInterface.PCTP%' OR [cs-uri-stem] LIKE '%ErrorHandler%' or cs-uri-query like '%RumbaLogoutServiceDown%'"
		logparser -i:IISW3C $IISLogQuery -o:XML -oCodepage:1252 -iCheckpoint:iislogerr.$FullHostName.lpc >> log
				
		# extract events of interest from database system event log
		if(!($DatabaseName -eq ""))
		{
			$strDBHost = $DatabaseName -split ","
			foreach($DBServer in $strDBHost)
			{
				
				logparser -i:EVT "SELECT TO_DATE(TimeGenerated) as date,TO_TIME(TimeGenerated) as time,EventTypeName as s-sitename,ComputerName,'$IP' as c-ip, EventID as sc-status,SourceName as cs-cookie,SUBSTR(Message,0,2000) as Message INTO events.$DBServer.xml FROM '\\$DBServer\Application' WHERE EventType IN (1;2) AND SourceName like '%MSSQLSERVER%' ORDER BY date, time" -o:XML -oCodepage:1252 -iCheckpoint:events.$DBServer.lpc >> log
			}
		}
	}
	
	#Removing all the xml file those are having zero bytes.
	#Get-ChildItem -filter "*.xml" | where {$_.length -eq 0 } | Remove-Item
	
	Write-Host rollupsummary HTML Generating
	# complain if more than 100 errors in the past hour
		logparser -i:XML "SELECT DISTINCT count(*) as hits,COALESCE(TO_STRING(sc-status),cs-cookie) as status,substr([Message],0,1600) as Message INTO rollupreport.html FROM '*.xml' GROUP BY status,Message having hits > 100 ORDER BY hits DESC"  -o:TPL -tpl:.\rollupsummary.tpl -e:100 >> log
				
	Write-Host errorsummary HTML Generating	
	# complain if any serious error is found
	    logparser -i:XML "SELECT date,time,s-sitename,TO_LOWERCASE(ComputerName) as ComputerName,c-ip,sc-status,cs-cookie,substr([Message],0,1600) as Message INTO report.html FROM '*.xml' WHERE Message like '%OutOfMemoryException%' or Message like '%Faulting application w3wp.exe%' OR sc-status = '5000' ORDER By date, time, s-sitename" -o:TPL -tpl:.\errorsummary.tpl -e:100 >> log
    	
	#Calling ZIP Function
	. $PSFunctionLib
	Zip -FileToZip *.html -ZipFile $FileName
	
	. $PSFunctionLib
	CopyToSummary -Site $Site -FileName $FileName -SUMMARYDIR $SUMMARYDIR
	
	#Condition if rollupreport file exist and size is greater than zero
	if(Test-Path rollupreport.html)
	 {
	   [int] $Size = (Get-Item rollupreport.html).Length
		if($Size -gt 0)
			{
				sendzipmail -subject $subject -users  $EmailTo -File "$(get-location)\rollupreport.html"
			}
	 }
	 
	#Condition if report file exist and size is greater than zero
	if(Test-Path report.html)
	{
		[int] $Size = (Get-Item report.html).Length
		if($Size -gt 0)
			{
				sendzipmail -subject $subject -users  $EmailTo -File "$(get-location)\report.html"
			}
	}

}


HourlyErrorCheck -Site SCHOOLVM -HostName PEGFEQAV -HostNumber "12,13" -DatabaseName "" -Subject "[Powershell] 5.14 School VM Hourly Summary" -EmailTo $MYMAIL -EmailCC "" -IISLogFile "W3SVC1"
HourlyErrorCheck -Site HEDVM -HostName PEGFEQAV -HostNumber "10,11" -DatabaseName "" -Subject "[Powershell] 5.14 HED VM Hourly Summary" -EmailTo $MYMAIL -EmailCC "" -IISLogFile "W3SVC"

#errorsummary -Site 'core' -HostName 'PEGFEINSTALLER' -HostNumber "" -DatabaseName "COREDB" -Subject "PEGV - core" -EmailTo "ALLMAIL" -EmailCC "ROLLUPALLMAIL";

#errorsummary -Site 'test' -HostName 'pegasusprod' -HostNumber "31" -DatabaseName "" -Subject "$PEGV - test" -EmailTo "$MYMAIL" -EmailCC "$MYMAIL"
#errorsummary -Site 'core' -HostName 'pegfeprodv' -HostNumber "$CORE" -DatabaseName "$COREDB" -Subject "$PEGV - core" -EmailTo "$ALLMAIL" -EmailCC "$ROLLUPALLMAIL"
#errorsummary -Site 'myitlab' -HostName 'pegasusprod' -HostNumber "$MYITLAB" -DatabaseName "$MYITLABDB" -Subject "3.9.4 - myitlab" -EmailTo "$ALLMAIL" -EmailCC "$ROLLUPALLMAIL"
#errorsummary -Site 'download' -HostName 'pegfeprodv' -HostNumber "50,51,52" -DatabaseName "" -Subject "$PEGV - download" -EmailTo "$ALLMAIL" -EmailCC "$ROLLUPALLMAIL"
#errorsummary -Site 'sim' -HostName 'pegasusrep' -HostNumber "$SIM" -DatabaseName "$SIMDB" -Subject "$PEGV - repository" -EmailTo "$ALLMAIL" -EmailCC "$ROLLUPALLMAIL"
#errorsummary -Site 'school' -HostName 'pegfeprodv'-HostNumber "$SCHOOL" -DatabaseName "$SCHOOLDB" -Subject "5.9 - school" -EmailTo "$ALLMAIL" -EmailCC "$ROLLUPALLMAIL"
#errorsummary -Site 'schoolrep' -HostName 'pegasusrep' -HostNumber "$SCHOOLREP" -DatabaseName "" -Subject "$PEG4V - school" -EmailTo "$ALLMAIL" -EmailCC "$ROLLUPALLMAIL"
#errorsummary -Site 'gradeit' -HostName 'pegfeprodv' -HostNumber "40,41,42,43,44,45" -DatabaseName "" -Subject "1.0 - GradeIT" -EmailTo "$ALLMAIL" -EmailCC "$ROLLUPALLMAIL"
#errorsummary -Site 'plt' -HostName 'pegasusprod' -HostNumber "21,22,23" -DatabaseName "pegdb1516sql" -Subject "3.2.2 - PLT" -EmailTo "$ALLMAIL" -EmailCC "$ROLLUPALLMAIL"
#errorsummary -Site 'writingcoach' -HostName 'pegasus' -HostNumber "09,10" -DatabaseName "" -Subject "5.5 - Writing Coach Demo" -EmailTo "$MYMAIL" -EmailCC "$ROLLUPALLMAIL"
#errorsummary -Site 'auth55' -HostName 'pegasusprod' -HostNumber "06,07,08,09" -DatabaseName "b03pegclu03-i"-Subject "5.5 - School, HED and MyITLab authoring" -EmailTo "$MYMAIL" -EmailCC "$MYMAIL"
#errorsummary -Site 'mylabs' -HostName 'pegfeprodv' -HostNumber "$MYLABS" -DatabaseName "$MYLABSDB" -Subject "5.9 - MyLabs" -EmailTo "$ALLMAIL" -EmailCC "$ROLLUPALLMAIL"