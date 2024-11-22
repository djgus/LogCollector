<# ········· collect logs - v4.0.8 ···········
- set hosts on $hosts array variable
- change destination path on $storage variable
- set $daysToKeep to configure your retention policy
············································ #>

<# define a list of host machine names in an array #>
$hosts = @("CORE.gus.local", "DB.gus.local")
$date = Get-Date -Format yyMMdd_HHmmss

<# destination for logs collected #>
$storage = "\\core\repo\logs\"

<# configure log retention days #>
$daysToKeep = 7

<# folder to backup on each machine #>
$LogDirectory = "c$\ProgramData\Dalet\DaletLogs"
$desP = "$storage"

<# running this script from task scheduler, the timezone needs to be converted #>
function get_date() {
    return [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date), 'Romance Standard Time')
}
<# log file path for this script #>
$GLOBAL_LogFile_TargetPath = "$storage\LogCollector_$($(get_date).toString("yyMMdd_HHmmss")).log"

function log_info($message) {
    $log = "[$($(Get-Date).toString("yyMMdd_HHmmss"))][INFO] $message"
    Write-Host $log -ForegroundColor "Green"
    $log >> $GLOBAL_LogFile_TargetPath.Replace("{DATE}", $(get_date).toString("yyMMdd"))
}

function log_error($message) {
    $log = "[$($(Get-Date).toString("yyMMdd_HHmmss"))][ERROR] $message"
    Write-Host $log -ForegroundColor "Red"
    $log >> $GLOBAL_LogFile_TargetPath.Replace("{DATE}", $(get-date).toString("yyMMdd"))
}

<# iterate through the list of hosts #>
foreach ($machine in $hosts) {
    log_info -message "$ iteration for $machine"
    $src="\\$machine\$LogDirectory"
    $dest="$storage\$machine"
    if (!(Test-Path -path $dest)) {New-Item $dest -Type Directory}
    if (!(Test-Path -path $dest\log)) {New-Item $dest\log -Type Directory}
    $desZip="$storage\$machine\$($date)_$($machine).zip"

    Start-Transcript -LiteralPath "$storage\$machine\log\log_$date.txt"
    Get-ChildItem -File -Path $src -Recurse -Depth 1 -Exclude *-info.log -Include *.log* | Where-Object {$_.LastWriteTime -ge (Get-Date).AddHours(-6)} | Copy-Item -Destination $dest

    <# 7zip files #>
    $7zip = $PSScriptRoot + "\7z.exe"
    Set-Alias Start-7Zip $7zip
    $7zsrc = Get-ChildItem -Path $dest -Exclude log, *.zip | Where-Object {$_.LastWriteTime -ge (Get-Date).AddMinutes(-30)}
    if ($null -ne $7zsrc) {Start-7Zip a -m0=lzma -mx=1 $desZip $7zsrc}

    <# purge garbage #>
    Get-ChildItem -LiteralPath $dest -File -Recurse | Remove-Item -Recurse -Force -Exclude *.zip, *.txt
    Stop-Transcript

    <# purge files older than #>
    Get-ChildItem $desP -Recurse -File | Where-Object CreationTime -lt (Get-Date).AddDays(-$daysToKeep) | Remove-Item -Force
}