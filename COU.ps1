# 2017/10/06 AcidVenom v6.1
# Скрипт выкачивания обнов для COU
# Параметры запуска скрипта: cis, av, av-clean

param($1)

#######################################################################
#################### ПОЛЬЗОВАТЕЛЬСКИЕ ПЕРЕМЕННЫЕ ######################

$7z = "C:\Program Files\7-Zip\7z.exe"            # Путь к 7z.exe
$downloadpath = "C:\inetpub\wwwroot"             # Путь хранения
$serverurl = "https://cdn.download.comodo.com"   # Сервер Comodo
$inis = "5070"                                   # Ветка обновления
$proto = "10"                                    # Версия распознователя
$xx = "x32","x64"                                # Битность для скачивания ("x32","x64")
$cispacked = $True                               # Скачивание упакованных (*.7z) обновлений ($True/$False)
$avpacked = $True                                # Скачивание упакованных (*.cav.z) баз ($True/$False)
$release_notes = $True                           # Качать Release Notes? ($True/$False)

#######################################################################
###################   СЛУЖЕБНЫЕ ПЕРЕМЕННЫЕ   ##########################

$inispath = "$downloadpath\cis\download\updates\release\inis_$inis"
$recognizerspath = "$inispath\recognizers\proto_v$proto"
$updates58path = "$downloadpath\av\updates58"
$updatesurlpath = "$downloadpath\av\updatesurl"
$basespath = "$updates58path\sigs\bases"
$updatespath = "$updates58path\sigs\updates"
$urlpath = "$updatesurlpath\sigs\updates"
$tvlpath = "$downloadpath\av\tvl"

$inisurl = "$serverurl/cis/download/updates/release/inis_$inis"
$recognizersurl = "$inisurl/recognizers/proto_v$proto"
$updates58url = "$serverurl/av/updates58"
$updatesurlurl = "$serverurl/av/updatesurl"
$basesurl = "$updates58url/sigs/bases"
$updatesurl = "$updates58url/sigs/updates"
$urlurl = "$updatesurlurl/sigs/updates"
$tvlurl = "$serverurl/av/tvl"

#######################################################################
###############   СКАЧИВАНИЕ ОБНОВЛЕНИЙ ПРОГРАММЫ   ###################

if ($1 -eq "cis") {

if ($cispacked -eq $True) {$packed = ".7z"} else {$packed = ""}

# Updates

$testinis = Test-Path $inispath
$testrecognizers = Test-Path $recognizerspath
if ($testinis -eq $False) {New-Item -ItemType Directory -path $inispath}
if ($testrecognizers -eq $False) {New-Item -ItemType Directory -path $recognizerspath}

foreach ($x in $xx) {
Invoke-WebRequest -Uri "$inisurl/cis_update_$x.xml$packed" -OutFile "$inispath/cis_update_$x.xml$packed"
if ($cispacked -eq $True) {& $7z x -o"$inispath" $inispath\cis_update_$x.xml.7z -y}
$lines = Get-Content $inispath\cis_update_$x.xml | ? {$_ -match "<file name=" -and $_ -notmatch "\\"}

foreach ($line in $lines) {
$line = $line -split " "
$name = $line -match "name="
$name = $name -replace "name=|`"",""
$sha = $line -match "sha="
$sha = $sha -replace "sha=|`"",""
$sha = $sha.toupper()
$src = $line -match "src="
$src = $src -replace "src=|`"|>",""
$srcf = $src.substring(0,$src.lastindexof("/"))
$srcp = $src -replace "\/","\"

$fileexist = Test-Path "$inispath\$srcp$packed"
$folderexist = Test-Path "$inispath\$srcf"

if ($fileexist -eq $True) {
$remove = $False
if ($cispacked -eq $True) {
try {
$remove = $True
& $7z x -o"$inispath/$srcf" $inispath/$srcp.7z -y
}
catch {}
}
$hash = Get-FileHash "$inispath/$srcp" -Algorithm SHA1
if ($remove -eq $True) {Remove-Item "$inispath\$srcp"}
if ($hash.Hash -eq $sha) {Continue}
}
if ($folderexist -eq $False) {New-Item -ItemType Directory -path "$inispath\$srcf"}
try {Invoke-WebRequest -Uri "$inisurl/$src$packed" -OutFile "$inispath/$srcp$packed"}
catch {Invoke-WebRequest -Uri "$inisurl/$src" -OutFile "$inispath/$srcp"}

}
if ($cispacked -eq $True) {Remove-Item "$inispath\cis_update_$x.xml"}

# Recognizers

Invoke-WebRequest -Uri "$recognizersurl/cmdscope_update_$x.xml$packed" -OutFile "$recognizerspath/cmdscope_update_$x.xml$packed"
if ($cispacked -eq $True) {& $7z x -o"$recognizerspath" $recognizerspath\cmdscope_update_$x.xml.7z -y}
$lines = Get-Content $recognizerspath\cmdscope_update_$x.xml | ? {$_ -match "<file name=" -and $_ -notmatch "\\"}

foreach ($line in $lines) {
$line = $line -split " "
$name = $line -match "name="
$name = $name -replace "name=|`"",""
$sha = $line -match "sha="
$sha = $sha -replace "sha=|`"",""
$sha = $sha.toupper()
$src = $line -match "src="
$src = $src -replace "src=|`"|>",""
$srcf = $src.substring(0,$src.lastindexof("/"))
$srcp = $src -replace "\/","\"

$fileexist = Test-Path "$recognizerspath\$srcp$packed"
$folderexist = Test-Path "$recognizerspath\$srcf"


if ($fileexist -eq $True) {
$remove = $False
if ($cispacked -eq $True) {
try {
$remove = $True
& $7z x -o"$recognizerspath/$srcf" $recognizerspath/$srcp.7z -y
}
catch {}
}
$hash = Get-FileHash "$recognizerspath/$srcp" -Algorithm SHA1
if ($remove -eq $True) {Remove-Item "$recognizerspath\$srcp"}
if ($hash.Hash -eq $sha) {Continue}
}
if ($folderexist -eq $False) {New-Item -ItemType Directory -path "$recognizerspath\$srcf"}
try {Invoke-WebRequest -Uri "$recognizersurl/$src$packed" -OutFile "$recognizerspath/$srcp$packed"}
catch {Invoke-WebRequest -Uri "$recognizersurl/$src" -OutFile "$recognizerspath/$srcp"}

}

if ($cispacked -eq $True) {Remove-Item "$recognizerspath\cmdscope_update_$x.xml"}
}

##################################################
#Release Notes

if ($release_notes -eq $True) {
$rn = "ComodoLogo.png","Fixed.png","Header.png","Improved.png","Logo.png","New.png","Panel_body.png","Panel_footer.png","Panel_header.png","Panel_left_body.png","Panel_left_footer.png","Panel_left_header.png","Panel_left_hr.png"
$testrn = Test-Path "$inispath\images"
if ($testrn -eq $False) {New-Item -ItemType Directory -Path "$inispath\images"}
Invoke-WebRequest -Uri "$inisurl/release_notes.html" -OutFile "$inispath/release_notes.html"
foreach ($r in $rn) {Invoke-WebRequest -Uri "$inisurl/images/$r" -OutFile "$inispath/images/$r"}
}
}

#######################################################################
###################   СКАЧИВАНИЕ ОБНОВЛЕНИЙ БАЗ   #####################

elseif ($1 -eq "av") {

if ($avpacked -eq $True) {$packed = ".z"} else {$packed = ""}

#updates58

$folders = "$basespath","$updatespath","$urlpath","$tvlpath"
foreach ($folder in $folders) {
$testfolder = Test-Path "$folder"
if ($testfolder -eq $False) {New-Item -ItemType directory -Path "$folder"}
}

Invoke-WebRequest -Uri "$tvlurl/delven.txt" -OutFile "$tvlpath\delven.txt"

Invoke-WebRequest -Uri "$updates58url/versioninfo.ini" -OutFile "$updates58path\versioninfo.ini"
$file = Get-Content "$updates58path\versioninfo.ini"
$base = $file | Where {$_ -match "MaxBase="}
$base = $base.substring(8)/1
$inc = $file | Where {$_ -match "MaxAvailVersion="}
$inc = $inc.substring(16)/1
$diff = $file | Where {$_ -match "MaxDiff="}
$diff = $diff.substring(8)/1
$incr = $inc - $diff + 1
if ($incr -gt $base) {$incr = $base + 1}

$testbases = Test-Path "$basespath\BASE_END_USER_v$base.cav$packed"
if ($testbases -eq $False) {Invoke-WebRequest -Uri "$basesurl/BASE_END_USER_v$base.cav$packed" -OutFile "$basespath\BASE_END_USER_v$base.cav$packed"}

do {
$testupdates = Test-Path "$updatespath\BASE_UPD_END_USER_v$incr.cav$packed"
if ($testupdates -eq $False) {Invoke-WebRequest -Uri "$updatesurl/BASE_UPD_END_USER_v$incr.cav$packed" -OutFile "$updatespath\BASE_UPD_END_USER_v$incr.cav$packed"}
$incr++
}
while ($incr -le $inc)

# updatesurl

Invoke-WebRequest -Uri "$updatesurlurl/versioninfo.ini" -OutFile "$updatesurlpath\versioninfo.ini"
$file = Get-Content "$updatesurlpath\versioninfo.ini"
$base = $file | Where {$_ -match "MaxBase="}
$base = $base.substring(8)
$inc = $file | Where {$_ -match "MaxAvailVersion="}
$inc = $inc.substring(16)
$incr = $base/1 + 1

do {
$testupdatesurl = Test-Path "$urlpath\BASE_UPD_END_USER_v$incr.cav.z"
if ($testupdatesurl -eq $False) {Invoke-WebRequest -Uri "$urlurl/BASE_UPD_END_USER_v$incr.cav.z" -OutFile "$urlpath\BASE_UPD_END_USER_v$incr.cav.z"}
$incr++
}
while ($incr -le $inc)
}

#######################################################################
#####################   УДАЛЕНИЕ УСТАРЕВШИХ БАЗ   #####################

elseif ($1 -eq "av-clean") {

if ($avpacked -eq $True) {$packed = ".z"} else {$packed = ""}

$test58ver = Test-Path "$updates58path\versioninfo.ini"
$testurlver = Test-Path "$updatesurlpath\versioninfo.ini"
#$message = ""

if ($test58ver -eq $True) {
$file = Get-Content "$updates58path\versioninfo.ini"
$base = $file | Where {$_ -match "MaxBase="}
$base = $base.substring(8)/1
$aval = $file | Where {$_ -match "MaxAvailVersion="}
$aval = $aval.substring(16)/1
$diff = $file | Where {$_ -match "MaxDiff="}
$diff = $diff.substring(8)/1
$del = $aval - $diff + 1
if ($del -gt $base) {$del = $base + 1}

$names = (Get-ChildItem -Path "$basespath").basename -replace "BASE_END_USER_v|.cav",""
foreach ($name in $names) {
$name = $name/1
if ($name -lt $base) {Remove-Item "$basespath\BASE_END_USER_v$name.cav$packed"}
}

$names = (Get-ChildItem -Path "$updatespath").basename -replace "BASE_UPD_END_USER_v|.cav",""
foreach ($name in $names) {
$name = $name/1
if ($name -lt $del) {Remove-Item "$updatespath\BASE_UPD_END_USER_v$name.cav$packed"}
}
}

if ($testurlver -eq $true) {
$file = Get-Content "$updatesurlpath\versioninfo.ini"
$aval = $file | Where {$_ -match "MaxAvailVersion="}
$aval = $aval.substring(16)/1
$diff = $file | Where {$_ -match "MaxDiff="}
$diff = $diff.substring(8)/1
$del = $aval - $diff

$names = (Get-ChildItem -Path "$urlpath").basename -replace "BASE_UPD_END_USER_v|.cav",""
foreach ($name in $names) {
$name = $name/1
if ($name -lt $del) {Remove-Item "$urlpath\BASE_UPD_END_USER_v$name.cav.z"}
}
}

}

#######################################################################
####################   ВЫХОД ПРИ ДРУГОМ ПАРАМЕТРЕ   ###################

else {exit}
