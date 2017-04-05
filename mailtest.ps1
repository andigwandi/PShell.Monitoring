$SMTPHost = "mailhost.pearsoncmg.com"
$EmailTo = "kumara.chikkaboraiah@excelindia.com","Tejaswi@excelindia.com","laxman.puri@excelindia.com"
$EmailFrom = "dontreply@pearsoncmg.com"
$EmailSubject = "Dead letter queue | Purged"
$logf = "D:\Pegasus\PShell\msmqmng\testlog.log"
$ff="D:\Pegasus\PShell\msmqmng\purgeresult.log"
Get-Content $ff | Select-String -pattern "MSMQ>purge /p FormatName:Direct=os:", "Complete in", "Failed after"| Out-File $logf
$logfinal=Get-Content $logf | Out-String
Send-MailMessage -from $EmailFrom -to $EmailTo -subject "Testing | please ignore" -body "Testing" -smtpServer $SMTPHost -OutVariable out
$out 
