#Used to copy the ZipFile from one place to another by taking zipfilename,site,serverdir as a parameter.
function CopyToSummary([String] $Site,[String] $FileName,[String] $SUMMARYDIR)
{   
    Write-Host Inside CopytoSummary
	$currentdate=(Get-Date).ToString("yyyyMMdd")
	$SUMMARY = Join-Path $SUMMARYDIR $Site\$currentdate
	if(!(Test-Path -path $SUMMARY))
	{
		mkdir $SUMMARY
	}
	$NewFileName = ((Get-Date).ToString("hhmmss") + ".zip")
	$ZipFilePath = "$(get-location)\$FileName.zip"
	Move-Item -Path $ZipFilePath -Destination $SUMMARY\$NewFileName
	Write-Host Exiting CopyToSummary
}
#Zip the file by taking filename,zipfilename as a parameter.
function ZIP([String] $FileToZip,[String] $ZipFile)
{  
  $FileFullPath = Get-ChildItem $FileToZip | ForEach {$_.FullName}
  write-host $FileFullPath
  #$ZipFilePath = $FileFullPath|split-path -parent
  $ZipFilePath = "$(get-location)\$ZipFile.zip"
  set-content $ZipFilePath ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18)) 
  $Zip = (new-object -com shell.application).NameSpace($ZipFilePath) 
  Get-ChildItem $FileToZip | foreach {$Zip.CopyHere($_.FullName);Start-Sleep -s 10} 
  Start-Sleep -s 10
}