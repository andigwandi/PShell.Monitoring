# ==========================================================================
#
# Script Name: Archive.ps1
#
# Author: Ashutosh Kumar
#
# Date Created: 15/10/2012
#
# This script can be used to pick the 3 days older IIS .gz logs and archieve it to different location
#  
# =========================================================================

. D:\Pegasus\PShell\IISArchieve\Master.ps1
# Function with Paramenter $CommonNodeName and $NodeValue
   function archieve([string]$CommonNodeName, $NodeValue)
   {
   foreach ($i in $NodeValue)#picking all the node values
   		{
		$Computers = @("\\$CommonNodeName$i")
		$Sourcepath= "$Computers\D$\inetpub\logs\LogFiles\W3SVC1\*.gz"
		$DestinationPath="$Computers\C$\IISLogArchive\WSS3.0\W3SVC1"
		foreach ($it in gci $Sourcepath)#Process each item in the $Sourcepath
            {
			foreach ($i in gci $it.FullName)
            {
				if ($i.LastWriteTime -lt ((Get-Date).AddDays(-3))) #picking files with current date-3
                {
                $dest = Join-Path "$DestinationPath" $it.Name 
                move-Item $i.FullName $dest #Moving logs to destination Path 
  		        }
            }
         	}
      	}
   	}
	



