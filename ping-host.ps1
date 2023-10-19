<#
.SYNOPSIS
Ping one or multiple hosts then get a very informative and pleasant-looking result

.DESCRIPTION		
Tweak the Test-Connection cmdlet available in powershell and make it Presentable with extended functionalities such as Colors, Host Status, Success and Failure Percentage, Number of ICMP Attempts.       

.PARAMETER Hosts
A description of the Hosts parameter.

.PARAMETER ToCsv
A description of the ToCsv parameter.

.EXAMPLE
Ping Multiple Hostnames at a time
PS C:\> Ping-Host '127.0.0.1','localhost','192.168.0.14','192.168.0.16','192.168.0.50','192.168.0.60'

Ping Range of IP address at a time
PS C:\> Ping-Host (100..150|%{"10.0.50.$_"})

Ping a list of Hostname in one go
PS C:\> Ping-Host -Hosts (gc C:\list.txt)

Ping Hostnames queried from ActiveDirectory
PS C:\> Ping-Host -Hosts ((Get-ADComputer -Filter {name -like 'LSP*-DSP*'}).name})

.NOTES
Additional information about the function.
#>

function Ping-Host
{
[CmdletBinding(HelpUri = ' https://geekeefy.wordpress.com/2015/07/16/powershell-fancy-test-connection/')]
[OutputType([string])]
param
(
[Parameter(Position = 0)]
$Hosts,
[Parameter]$ToCsv
)
Function Make-Space($l, $Maximum)
{
$space = ""
$s = [int]($Maximum - $l) + 1
1 .. $s | %{ $space += " " }
return [String]$space
}
$LengthArray = @()
$Hosts | %{ $LengthArray += $_.length }
$Maximum = ($LengthArray | Measure-object -Maximum).maximum
$Count = $hosts.Count
$Success = New-Object int[] $Count
$Failure = New-Object int[] $Count
$Total = New-Object int[] $Count
cls
while ($true)
{		
$i = 0
$out = "| HOST$(Make-Space 4 $Maximum)| STATUS | SUCCESS  | FAILURE  | ATTEMPTS  |"
$Firstline = ""
1 .. $out.length | %{ $firstline += "_" }
Write-Host $Firstline
Write-host $out -ForegroundColor White -BackgroundColor Black
$Hosts | %{
$total[$i]++
If (Test-Connection $_ -Count 1 -Quiet -ErrorAction SilentlyContinue)
{
$success[$i] += 1
$SuccessPercent = $("{0:N2}" -f (($success[$i]/$total[$i]) * 100))
$FailurePercent = $("{0:N2}" -f (($Failure[$i]/$total[$i]) * 100))
Write-Host "| $_$(Make-Space $_.Length $Maximum)| UP$(Make-Space 2 4)  | $SuccessPercent`%$(Make-Space ([string]$SuccessPercent).length 6) | $FailurePercent`%$(Make-Space ([string]$FailurePercent).length 6) | $($Total[$i])$(Make-Space ([string]$Total[$i]).length 9)|" -BackgroundColor Green
}
else
{
$Failure[$i] += 1
$SuccessPercent = $("{0:N2}" -f (($success[$i]/$total[$i]) * 100))
$FailurePercent = $("{0:N2}" -f (($Failure[$i]/$total[$i]) * 100))
Write-Host "| $_$(Make-Space $_.Length $Maximum)| DOWN$(Make-Space 4 4)  | $SuccessPercent`%$(Make-Space ([string]$SuccessPercent).length 6) | $FailurePercent`%$(Make-Space ([string]$FailurePercent).length 6) | $($Total[$i])$(Make-Space ([string]$Total[$i]).length 9)|" -BackgroundColor Red
}
$i++			
}
Start-Sleep -Seconds 4
cls
}
}
