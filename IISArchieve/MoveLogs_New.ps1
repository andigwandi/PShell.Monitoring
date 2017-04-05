# Global Variables needed for this scripts
# Variable path for source location of log file
$LogSourcePath = 'C:\Program Files\Microsoft SQL Server\MSRS10_50.MSSQLSERVER2008\Reporting Services\LogFiles'
# Varible Archieve for destination location of log file
$ARCHIVE='C:\Users\shilpi.ahuja\Desktop\Log'
# Extension of the files used for archive
$ext="*.log"
function moveziplogs([String] $days, [String] $HostName,[String] $HostNumber)
{
	$strHost = $HostNumber -split ","
    foreach($HostPostfix in $strHost)
    {
		# Get the Full Host name
		$FullHostName=$HostName+$HostPostfix
		$HostWithDomainName="$FullHostName.wrk.pad.pearsoncmg.com"
		$ArchiveDestination="$ARCHIVE\$HostWithDomainName"
		if(!(Test-Path -path $ArchiveDestination))
		{
			mkdir $ArchiveDestination
		}
		Get-Childitem -Path $LogSourcePath -Recurse -Include $ext | Where-Object {$_.LastWriteTime -lt (get-date).AddDays(-$days)} | foreach {
			$SourceFile = $_.Name
			write-host $_.LastWriteTime
			$SourceFilePath = "$LogSourcePath\$SourceFile"		
			Move-Item -Path $SourceFilePath -Destination $ArchiveDestination -Force
		}
	}
}
moveziplogs -days 50 -HostName "NOICLT" -HostNumber "207"