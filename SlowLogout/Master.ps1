$Log="D:\inetpub\logs\LogFiles\W3SVC1\slowlogout2.txt"
$stdout="D:\Pegasus\PShell\SlowLogout\stdout.xml"
$EmailTo = “shilpi.ahuja@imfinity.com”
$EmailFrom = “ashutosh.kumar@imfinity.com”
$SMTPServer = “mailhost.pearsoncmg.com”
$query = @”
Select count(*) as hits into $stdout from $Log where cs-uri-query like '%%RumbaLogoutServiceDown%%'
“@
$FileExists =(Test-Path $stdout)
 