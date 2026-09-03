<#
    Cai app su kien Vietnam Sourcing 2026 len robot BellaBot Pro.

        .\cai-len-robot.ps1                    # cai het: APK + giao dien + anh/video + giong + cau hinh
        .\cai-len-robot.ps1 -Ip 192.168.1.183  # chi ro IP robot, khoi phai do tim
        .\cai-len-robot.ps1 -ChiKiemTra        # chi xem may dang co gi, khong dong vao
        .\cai-len-robot.ps1 -ChiGiaoDien       # chi day index.html + anh + video (nhanh nhat)
        .\cai-len-robot.ps1 -ChiGiong          # chi day file MP3 giong doc
        .\cai-len-robot.ps1 -ChiCauHinh        # chi day telegram.json
        .\cai-len-robot.ps1 -LayNhatKy         # keo cau thieu tieng + hang doi Telegram ve

    ═══ MOT SCRIPT, HAI NOI CHAY ═══

    ① Trong workspace cua Roboworld:  11-app-pudu\su-kien-sourcing-2026\tools\
       Lay APK tu android\...\app-debug.apk, giao dien tu demo\, giong tu giong\.

    ② Trong BO CAI ROI gui cho ky thuat vien: script nam canh noi-dung\ va app\
       Lay het tu hai thu muc do, va dung adb dong goi san trong adb\.

    ⚠ CO Y GIU MOT BAN DUY NHAT. Ky thuat vien o hien truong chay dung cai script
      da thu o nha; hai ban sao thi ban gui di se troi khoi ban minh thu, ma nguoi
      chiu la nguoi dung mot minh truoc con robot, khong goi ai duoc.
      Dong goi bang:  python tools\dong-goi-cai-dat.py

    ⚠ ANH VA VIDEO KHONG NAM TRONG APK. Tong ~270 MB — nhet vao APK thi moi lan
      sua mot chu phai day lai ca goi qua Wi-Fi. Chung nam o the nho:

        /sdcard/Android/data/com.pudutech.business.sourcing/files/web/

      Doi noi dung (them anh, sua gia, doi vi tri gian hang) chi can chay
      dung-app.py roi -ChiGiaoDien. KHONG phai build lai APK.

    ⚠ PHAI dung adb 1.0.41 cua Android SDK. Ban C:\Windows\adb.exe la adb 1.0.39
      cua PUDU va NAM TREN PATH — go `adb` tran la trung no, hai ban giet tien
      trinh cua nhau roi rot lien tuc. Bo cai roi dong goi san adb dung ban.

    ⚠ Git Bash bien /sdcard thanh D:/Git/sdcard. Script nay chay bang PowerShell
      nen khong dinh, nhung neu chay tay bang Git Bash thi phai
      `export MSYS_NO_PATHCONV=1` truoc.

    ⚠ MOI CHU IN RA MAN HINH DEU LA ASCII, khong dau tieng Viet, khong ky tu ke
      khung. Cua so PowerShell 5.1 dung bang ma OEM cua may — chu co dau in ra
      thanh rac, ma ky thuat vien doc rac thi tuong app hong.

    ⚠ BELLABOT PRO KHONG CAI QUA CAP USB. Anh Truong chot 01/09/2026: dong may nay
      cap nhat phan mem QUA MANG, khong cam day. Nen buoc noi may la `adb connect
      <IP>:5555`, va may tinh phai NAM CUNG MANG Wi-Fi voi robot.
      (Cap USB o dau may la cach cua GreetingBot Nova — dung lan sang day.)

      Khong biet IP thi khong sao: script tu do ca lop mang, hoi cong 5555.
      Tim thay thi nho IP lai vao ip-robot.txt, lan sau khoi do.

    Robot phai BAT "Go loi lau dai" va DA KHOI DONG LAI thi adb moi noi duoc.
    Bat moi "Go loi" thoi thi mat sau khi reboot.
#>
param(
    [string]$Ip,
    [switch]$ChiKiemTra,
    [switch]$ChiGiaoDien,
    [switch]$ChiGiong,
    [switch]$ChiCauHinh,
    [switch]$LayNhatKy
)

$ErrorActionPreference = "Stop"
$Goi = "com.pudutech.business.sourcing"

$ThuMucApp = "/sdcard/Android/data/$Goi/files"
$ThuMucWeb = "$ThuMucApp/web"
$ThuMucGiong = "$ThuMucApp/tieng-noi"

# ── Dang chay o dau? ──────────────────────────────────────────
# Co thu muc noi-dung\ nam canh script  =>  bo cai roi.
$BoCaiRoi = Test-Path (Join-Path $PSScriptRoot "noi-dung")

if ($BoCaiRoi) {
    $Goc        = $PSScriptRoot
    $Noi        = Join-Path $Goc "noi-dung"
    $Index      = Join-Path $Noi "index.html"
    $ThuAnh     = Join-Path $Noi "anh-san-pham"
    $ThuVideo   = Join-Path $Noi "video"
    $ThuBieuCam = Join-Path $Noi "bieu-cam"
    $ThuGiongPC = Join-Path $Noi "tieng-noi"
    $Tele       = Join-Path $Noi "telegram.json"
    $ThuApk     = Join-Path $Goc "app"
    $Apk        = if (Test-Path $ThuApk) {
        $x = Get-ChildItem $ThuApk -Filter *.apk -File | Select-Object -First 1
        if ($x) { $x.FullName } else { Join-Path $ThuApk "khong-thay.apk" }
    } else { Join-Path $Goc "app\khong-thay.apk" }
} else {
    $Goc        = Split-Path -Parent $PSScriptRoot
    $Demo       = Join-Path $Goc "demo"
    $Index      = Join-Path $Demo "index.html"
    $ThuAnh     = Join-Path $Demo "anh-san-pham"
    $ThuVideo   = Join-Path $Demo "video"
    $ThuBieuCam = Join-Path $Demo "bieu-cam"
    $ThuGiongPC = Join-Path $Goc "giong"
    $Tele       = Join-Path $Goc "du-lieu\telegram.json"
    $Apk        = Join-Path $Goc "android\app\build\outputs\apk\debug\app-debug.apk"
}

# Cach chi viec lam lai — khac nhau giua hai noi chay, dung goi y nham.
$MachGiaoDien = if ($BoCaiRoi) { "Chay lai file CAI-DAT.bat" }
                else { "Chay truoc: python dung-app.py" }
$MachGiong    = if ($BoCaiRoi) { "Bo cai thieu thu muc noi-dung\tieng-noi - bao Roboworld gui lai bo cai" }
                else { "Sinh giong: python tools\sinh-giong.py --that-su-lam" }
$MachTele     = if ($BoCaiRoi) { "Bo cai thieu noi-dung\telegram.json - bao Roboworld gui lai bo cai" }
                else { "Tao bang: python tools\lay-chat-id.py --cho 120" }

# ── adb ──────────────────────────────────────────────────────
# Thu tu tim: adb dong goi kem > Android SDK > ban PUDU trong workspace > PATH.
$AdbExe = Join-Path $PSScriptRoot "adb\adb.exe"
if (-not (Test-Path $AdbExe)) { $AdbExe = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" }
if (-not (Test-Path $AdbExe) -and -not $BoCaiRoi) {
    $AdbExe = Join-Path (Split-Path -Parent (Split-Path -Parent $Goc)) "tools\pudu\platform-tools-pudu\adb.exe"
}
if (-not (Test-Path $AdbExe)) {
    Write-Host "Khong thay adb 1.0.41 - dung tam ban tren PATH (CO THE LA BAN 1.0.39 CUA PUDU)" -ForegroundColor Yellow
    $AdbExe = "adb"
}
function Adb { & $AdbExe @args }

# Dung san daemon adb. Lan dau chay no in "* daemon not running; starting now"
# lan giua ket qua, va tien trinh daemon giu lay ong xuat cua cua so — nhin
# nhu bi treo. Dung truoc roi nuot dong thong bao di cho gon.
Adb start-server 2>&1 | Out-Null

function Buoc($n, $chu) { Write-Host "`n[$n] $chu" -ForegroundColor Cyan }
function Loi($chu)      { Write-Host "  x  $chu" -ForegroundColor Red }
function Xong($chu)     { Write-Host "  OK $chu" -ForegroundColor Green }
function Nhac($chu)     { Write-Host "  !  $chu" -ForegroundColor Yellow }

Write-Host ""
Write-Host "  ROBOT BELLABOT PRO - VIETNAM SOURCING 2026" -ForegroundColor Cyan
Write-Host "  $(if ($BoCaiRoi) { 'Bo cai dat' } else { 'Thu muc du an' }): $Goc" -ForegroundColor DarkGray

# ══════════════ 1. Ket noi ══════════════
#
# BellaBot Pro di QUA MANG, khong cam cap USB. Ba duong thu theo thu tu:
#   ① -Ip nguoi dung go vao
#   ② IP lan truoc, nho trong ip-robot.txt
#   ③ do ca lop mang, hoi cong 5555
# Het ba duong moi hoi tay. Muc dich: ky thuat vien khong phai di tim IP robot
# trong menu cua hang giua luc hoi cho dong nguoi.

$TepIp = Join-Path $Goc "ip-robot.txt"

# Moi dong may trong `adb devices`, ke ca dong dang HONG.
# ⚠ PHAI GIU LAI CA DONG HONG. Ban truoc chi loc dong ket thuc bang "device" roi
#   coi moi truong hop con lai la "khong thay robot nao" — gop BA tinh huong khac
#   han nhau vao mot cau bao, khien nguoi o hien truong di sua nham cho:
#     device        = xong
#     unauthorized  = NOI DUOC ROI, chi thieu cu bam "Cho phep" TREN MAN HINH ROBOT
#     offline       = cong 5555 co mo nhung adb ben kia chua san sang
function DsMayRaw {
    @((Adb devices) -split "`n" |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and $_ -notmatch "^List of devices" -and $_ -notmatch "^\*" })
}

function DsMay {
    @(DsMayRaw | Where-Object { $_ -match "\sdevice$" })
}

# Trang thai may thay o lan cho gan nhat — de doan loi cho dung cho.
$script:TrangThaiCuoi = ""

# Cho robot HIEN RA trong `adb devices`. Noi xong khong hien ngay duoc: bat tay
# RSA mat vai giay, va may co the di qua trang thai "authorizing" truoc.
# ⚠ CO BA trang thai "chua duoc phep", khong phai hai:
#     unauthorized  — da hoi, nguoi dung chua tra loi
#     authorizing   — DANG hoi, hop thoai vua bat len
#     (device)      — xong
#   Ban truoc chi biet hai cai dau nen gap `authorizing` thi cho 10 giay roi bao
#   "khong noi duoc voi robot nao" — dung luc dang can nguoi ta nhin vao man hinh
#   robot ma bam mot nut. Dinh that o hien truong 03/09/2026.
#   Nay gap trang thai do thi KHONG BO CUOC: in han huong dan ra roi cho tiep 90
#   giay, du de nguoi trong ra cho robot va bam.
function ChoMay($d) {
    $ip = ($d -split ':')[0]
    $daNhac = $false
    $het = (Get-Date).AddSeconds(12)
    while ($true) {
        $dong = @(DsMayRaw | Where-Object { $_ -match [regex]::Escape($ip) })
        if ($dong) {
            $script:TrangThaiCuoi = ($dong -join " ")
            if ($dong -match "\sdevice$") {
                if ($daNhac) { Write-Host "" ; Xong "Robot da cho phep. Chay tiep." }
                return $true
            }
            if ($dong -match "authorizing|unauthorized") {
                if (-not $daNhac) {
                    $daNhac = $true
                    $het = (Get-Date).AddSeconds(90)
                    Write-Host ""
                    Write-Host "  ============================================================" -ForegroundColor Yellow
                    Write-Host "   ROBOT DANG HOI XIN PHEP - RA BAM NUT TREN MAN HINH ROBOT" -ForegroundColor Yellow
                    Write-Host "  ============================================================" -ForegroundColor Yellow
                    Write-Host @"
   Mang da thong roi, chi con thieu mot cu bam. Lam ngay tren ROBOT:

     1. Cham vao man hinh robot mot cai cho no sang
        (man hinh cho cua PUDU hay che mat hop thoai).
     2. Tim hop thoai "Allow USB debugging?" / "Cho phep go loi USB?"
        - co mot day ky tu dai ben duoi.
     3. TICH o "Always allow from this computer"
        (Luon cho phep tu may tinh nay).
     4. Bam ALLOW / OK / CHO PHEP.

   Dang cho 90 giay... bam xong la o day tu chay tiep, khong phai lam gi them.

   KHONG THAY HOP THOAI NAO? Tren robot vao Cai dat -> Debug, TAT
   'Go loi lau dai' roi BAT lai, sau do chay lai file .bat nay.
"@ -ForegroundColor Yellow
                    Write-Host "   Dang cho: " -NoNewline
                } else {
                    Write-Host "." -NoNewline
                }
            }
            elseif ($dong -match "offline") { return $false }
        }
        if ((Get-Date) -gt $het) {
            if ($daNhac) { Write-Host "" }
            return $false
        }
        Start-Sleep -Milliseconds 700
    }
}

function Noi($diaChi) {
    if (-not $diaChi) { return $false }
    $d = $diaChi.Trim()
    if ($d -notmatch ':\d+$') { $d = "${d}:5555" }

    # ⚠ NGAT TRUOC KHI NOI. adb hay giu lai mot muc ket noi CU DA CHET: lenh
    #   `connect` tra ve "already connected to ..." nghe rat yen tam, ma
    #   `adb devices` thi TRONG KHONG, va moi buoc sau deu hong ma khong hieu vi sao.
    #   Dinh that o hien truong 03/09/2026 (robot 10.112.255.25).
    #   Ngat truoc thi lan nao cung la bat tay lai tu dau.
    Adb disconnect $d 2>&1 | Out-Null
    $kq = (Adb connect $d) -join " "
    Write-Host "  $kq"
    if ($kq -notmatch "connected to") { return $false }

    Write-Host "  Dang cho robot san sang..." -ForegroundColor DarkGray
    if (ChoMay $d) { return $true }

    # Lan hai: dung han may chu adb roi dung lai. Chua duoc thi thoi.
    # ⚠ Tren may nay con mot ban adb khac cua PUDU o C:\Windows\adb.exe. Hai ban
    #   giet tien trinh cua nhau, va sau moi lan bi giet thi danh sach may mat sach.
    Write-Host "  Chua thay. Dung han may chu adb roi thu lai mot lan..." -ForegroundColor DarkGray
    Adb kill-server 2>&1 | Out-Null
    Adb start-server 2>&1 | Out-Null
    Adb connect $d 2>&1 | Out-Null
    return (ChoMay $d)
}

# Do ca lop mang, hoi cong 5555. Mo 254 socket mot luc roi cho chung, thay vi
# hoi lan luot — hoi lan luot het gan mot phut, ai cung bo cuoc truoc do.
function DoTimRobot {
    Write-Host "  Dang do tim robot tren mang (vai giay)..." -ForegroundColor DarkGray
    $tim = @()
    $mang = [System.Net.Dns]::GetHostAddresses([System.Net.Dns]::GetHostName()) |
            Where-Object { $_.AddressFamily -eq 'InterNetwork' -and
                           $_.ToString() -notlike '169.254.*' -and
                           $_.ToString() -ne '127.0.0.1' }
    foreach ($m in ($mang | Select-Object -First 2)) {
        $p = $m.ToString() -replace '\.\d+$', ''
        Write-Host "    lop mang $p.0/24" -ForegroundColor DarkGray
        $mo = @()
        foreach ($i in 1..254) {
            $c = New-Object System.Net.Sockets.TcpClient
            $mo += [pscustomobject]@{ Ip = "$p.$i"; C = $c
                                      A = $c.BeginConnect("$p.$i", 5555, $null, $null) }
        }
        Start-Sleep -Milliseconds 900
        foreach ($x in $mo) {
            if ($x.A.IsCompleted -and $x.C.Connected) { $tim += $x.Ip }
            $x.C.Close()
        }
        if ($tim) { break }
    }
    # Dau phay dung mot ngoi: GIU NGUYEN kieu mang khi tra ve, ke ca khi chi co
    # dung mot phan tu. Khong co no thi PowerShell bung mang thanh chuoi va ben
    # goi lay [0] ra duoc mot KY TU. Ben goi con boc them @() cho chac hai lop.
    return ,$tim
}

Buoc 1 "Ket noi robot qua Wi-Fi"
Write-Host "  BellaBot Pro cap nhat QUA MANG - khong cam cap USB."
Write-Host "  May tinh phai dung CHUNG mang Wi-Fi voi robot."

$daNoi = $false
if ($Ip) {
    $daNoi = Noi $Ip
} elseif (DsMay) {
    $daNoi = $true                      # ai do da connect tu truoc
} else {
    if (Test-Path $TepIp) {
        $cu = (Get-Content $TepIp -First 1).Trim()
        if ($cu) { Write-Host "  Thu lai IP lan truoc: $cu"; $daNoi = Noi $cu }
    }
    if (-not $daNoi) {
        # ⚠ PHAI BOC @(). PowerShell BUNG mang MOT phan tu thanh CHUOI khi tra ve
        #   tu ham. Luc do $thay.Count VAN la 1 (chuoi cung co .Count) nen nhanh
        #   duoi van chay, con $thay[0] lay ra KY TU DAU cua chuoi.
        #   Dinh that 03/09/2026 tai hien truong: robot o 10.112.255.25, script in
        #   "Thay mot may o 1" roi "cannot resolve host '1'". Ky thuat vien tuong
        #   mang hong, trong khi bo do da tim thay robot dung roi.
        $thay = @(DoTimRobot)
        if ($thay.Count -eq 1) {
            Xong "Thay mot may o $($thay[0])"
            $daNoi = Noi $thay[0]
        } elseif ($thay.Count -gt 1) {
            Write-Host "  Thay $($thay.Count) may mo cong 5555:" -ForegroundColor Yellow
            for ($i = 0; $i -lt $thay.Count; $i++) { Write-Host "    [$($i+1)] $($thay[$i])" }
            $c = Read-Host "  Chon so (Enter = 1)"
            if (-not $c) { $c = 1 }
            $daNoi = Noi $thay[[int]$c - 1]
        }
    }
    if (-not $daNoi) {
        Write-Host ""
        Nhac "Chua noi duoc. Go IP cua robot vao day."
        Write-Host "  Xem IP tren chinh man hinh robot:" -ForegroundColor Yellow
        Write-Host "     Cai dat  ->  Debug  ->  Device Information  ->  Ip Address"
        Write-Host "  Hoac xem trong trang quan ly may cua PUDU (Micro Remote)."
        $tay = Read-Host "  IP cua robot (vi du 10.112.255.25, Enter de bo qua)"
        if ($tay) { $daNoi = Noi $tay }
    }
}

$ds = DsMay
if (-not $ds) {
    $raw = DsMayRaw
    # "authorizing" cung nam o day: no la trang thai DANG hoi, chua ai tra loi.
    $chuaChoPhep = @($raw | Where-Object { $_ -match "unauthorized|authorizing" })
    $chuaSanSang = @($raw | Where-Object { $_ -match "offline" })

    if ($chuaChoPhep) {
        Loi "Robot DA NOI DUOC nhung CHUA CHO PHEP go loi."
        Write-Host @"
  $($chuaChoPhep -join "`n  ")

  DAY KHONG PHAI LOI MANG. Duong truyen da thong roi, chi thieu mot cu bam
  TREN MAN HINH ROBOT - va cu bam do khong lam thay tu may tinh duoc.

  LAM NGAY TREN ROBOT:
   1. Cham vao man hinh robot mot cai cho no sang.
      (Man hinh cho cua PUDU hay nam de len tren va che mat hop thoai.)
   2. Tim hop thoai "Allow USB debugging?" / "Cho phep go loi USB?"
      - co mot day ky tu dai ben duoi.
   3. TICH o "Always allow from this computer".
   4. Bam ALLOW / OK / CHO PHEP.
   5. Quay lai day, chay lai file .bat nay.

  KHONG THAY HOP THOAI NAO?
   - Tren robot: Cai dat -> Debug, TAT 'Go loi lau dai' roi BAT lai.
     Xong chay lai file .bat nay va NHIN MAN HINH ROBOT trong luc no chay.
   - Robot dang o man hinh cho hoac dang chay app thi hop thoai bi che.
     Dua robot ve man hinh Cai dat roi thu lai.
"@ -ForegroundColor Yellow
        exit 1
    }

    if ($chuaSanSang) {
        Loi "Thay robot nhung dang o trang thai 'offline'."
        Write-Host @"
  $($chuaSanSang -join "`n  ")

  Thu theo thu tu:
   1. Chay lai file .bat nay mot lan nua (hay duoc ngay lan hai).
   2. Van vay thi KHOI DONG LAI ROBOT, cho vao man hinh chinh roi chay lai.
   3. Kiem robot da bat 'Go loi lau dai' chua - bat moi 'Go loi' thoi thi
      mat sau khi tat may.
"@ -ForegroundColor Yellow
        exit 1
    }

    Loi "Khong noi duoc voi robot nao."

    # In nguyen van thu adb tra ve. Khong co doan nay thi moi truc trac deu trong
    # giong nhau tu ngoai vao, va nguoi o xa khong the doan giup duoc.
    Write-Host ""
    Write-Host "  --- adb devices tra ve nguyen van ---" -ForegroundColor DarkGray
    $tho = @((Adb devices) -split "`n" | ForEach-Object { $_.TrimEnd() })
    if ($tho) { $tho | ForEach-Object { Write-Host "  | $_" -ForegroundColor DarkGray } }
    else      { Write-Host "  | (khong co dong nao)" -ForegroundColor DarkGray }
    if ($script:TrangThaiCuoi) {
        Write-Host "  Trang thai thay luc cho: $($script:TrangThaiCuoi)" -ForegroundColor DarkGray
    }
    Write-Host "  Chup CA CUA SO NAY gui Roboworld neu phai goi ho tro." -ForegroundColor DarkGray
    Write-Host ""

    Write-Host @"
  Kiem tra lai theo thu tu nay:
   - Xem IP robot ngay tren man hinh no:
        Cai dat -> Debug -> Device Information -> Ip Address
     Roi chay lai va GO IP DO VAO khi duoc hoi.
   - May tinh va robot co dung CHUNG mot mang Wi-Fi khong?
     (Hoi cho hay co nhieu mang. Robot noi mang A ma may tinh noi mang B la
      khong bao gio thay nhau.)
   - Robot da bat 'Go loi lau dai' va DA KHOI DONG LAI chua?
   - IP robot co doi khong? Mang cap phat lai IP sau moi lan tat may.
     Nen xin nguoi quan tri mang DAT IP CO DINH cho robot.
   - Van khong duoc: goi Roboworld 0866 153 946
"@ -ForegroundColor Yellow
    exit 1
}
Xong "Da ket noi: $($ds -join ', ')"

# Nho IP lai cho lan sau. Chi ghi khi la dia chi mang, khong ghi may cam day.
# ⚠ Boc @() vi ly do y het cho tren: mot may thi $ds la CHUOI, khong phai mang.
$dc = (@($ds)[0] -split "\s+")[0]
if ($dc -match '^\d+\.\d+\.\d+\.\d+') {
    [System.IO.File]::WriteAllText($TepIp, ($dc -replace ':\d+$', ''),
        (New-Object System.Text.UTF8Encoding($false)))
}

$sn  = (Adb shell "getprop ro.serialno").Trim()
$rom = (Adb shell "getprop ro.build.display.id").Trim()
Write-Host "  SN: $sn"
Write-Host "  ROM: $rom"

# ══════════════ Chi kiem tra ══════════════
if ($ChiKiemTra) {
    Buoc 2 "Xem may dang co gi"
    $ban = (Adb shell "dumpsys package $Goi | findstr versionName").Trim()
    Write-Host "  App da cai : $(if ($ban) { $ban } else { 'CHUA CAI' })"
    $sw = (Adb shell "ls $ThuMucWeb 2>/dev/null | wc -l").Trim()
    $sa = (Adb shell "ls $ThuMucWeb/anh-san-pham 2>/dev/null | wc -l").Trim()
    $sv = (Adb shell "ls $ThuMucWeb/video 2>/dev/null | wc -l").Trim()
    $sg = (Adb shell "ls $ThuMucGiong 2>/dev/null | wc -l").Trim()
    $sb = (Adb shell "ls $ThuMucWeb/bieu-cam 2>/dev/null | wc -l").Trim()
    Write-Host "  Giao dien  : $sw muc trong web/"
    Write-Host "  Anh        : $sa tep"
    Write-Host "  Video SP   : $sv tep  (chieu tren man quang cao 18,5 inch)"
    Write-Host "  Bieu cam   : $sb tep  (chieu tren man chinh luc du hanh)"
    Write-Host "  Giong doc  : $sg tep MP3"
    $tele = (Adb shell "ls $ThuMucApp/telegram.json 2>/dev/null").Trim()
    Write-Host "  Telegram   : $(if ($tele) { 'da co cau hinh' } else { 'CHUA CO telegram.json' })"
    $thieu = (Adb shell "cat $ThuMucApp/thieu-tieng.txt 2>/dev/null | wc -l").Trim()
    Write-Host "  Cau thieu tieng: $thieu  (keo ve bang -LayNhatKy)"
    exit 0
}

# ══════════════ Lay nhat ky ══════════════
if ($LayNhatKy) {
    Buoc 2 "Keo nhat ky ve may tinh"
    $raw = Join-Path $Goc "nhat-ky-may-that"
    New-Item -ItemType Directory -Force $raw | Out-Null
    # ⚠ Dich cua adb pull phai viet kieu Windows. Viet /d/... la no bao
    #   "failed to stat" roi thoat lang le.
    Adb pull "$ThuMucApp/thieu-tieng.txt" $raw 2>&1 | Write-Host
    Adb pull "$ThuMucApp/telegram-cho-gui.json" $raw 2>&1 | Write-Host
    Write-Host ""
    $f = Join-Path $raw "thieu-tieng.txt"
    if (Test-Path $f) {
        $n = (Get-Content $f | Measure-Object -Line).Lines
        Xong "$n cau CHUA CO TIENG - robot da im lang o nhung cau nay"
        Write-Host "  Day la DANH SACH VIEC, khong phai loi. Xem: $f" -ForegroundColor Yellow
        Write-Host "  $MachGiong"
    } else {
        Xong "Khong co cau nao thieu tieng"
    }
    $g = Join-Path $raw "telegram-cho-gui.json"
    if (Test-Path $g) {
        Nhac "Con tin Telegram CHUA GUI DUOC - xem $g"
        Nhac "Thuong la mat mang. App tu gui lai moi 30 giay khi co mang."
    }
    exit 0
}

# ══════════════ 2. Cai APK ══════════════
$LamHet = -not ($ChiGiaoDien -or $ChiGiong -or $ChiCauHinh)

if ($LamHet) {
    Buoc 2 "Cai APK"
    if (-not (Test-Path $Apk)) {
        Loi "Chua co file APK: $Apk"
        if ($BoCaiRoi) {
            Write-Host "  Bo cai thieu thu muc app\ - bao Roboworld gui lai bo cai." -ForegroundColor Yellow
        } else {
            Write-Host "  Chay truoc: powershell tools\build-apk.ps1" -ForegroundColor Yellow
        }
        exit 1
    }
    $mb = [math]::Round((Get-Item $Apk).Length / 1MB, 1)
    Write-Host "  $(Split-Path -Leaf $Apk)  ($mb MB)"
    Adb install -r $Apk | Write-Host
    Xong "Da cai"

    # ⚠ Quyen doc /sdcard/pudu/appConfig/ — de app doc duoc muc "Am luong giong noi"
    #   can bo dat trong Cai dat robot. Khai trong Manifest CHUA DU tren Android 11+.
    #   Khong cap thi app van chay, chi dung muc mac dinh 70.
    Adb shell "appops set $Goi MANAGE_EXTERNAL_STORAGE allow" 2>&1 | Out-Null
    Xong "Da cap quyen doc cau hinh am luong cua hang"
}

# ══════════════ 3. Giao dien + anh + video ══════════════
if ($LamHet -or $ChiGiaoDien) {
    Buoc 3 "Day giao dien, anh va video len the nho"
    if (-not (Test-Path $Index)) {
        Loi "Chua co $Index"
        Write-Host "  $MachGiaoDien" -ForegroundColor Yellow
        exit 1
    }

    Adb shell "mkdir -p $ThuMucWeb/anh-san-pham $ThuMucWeb/video $ThuMucWeb/bieu-cam" | Out-Null
    Adb push $Index "$ThuMucWeb/index.html" | Write-Host

    if (Test-Path $ThuAnh) {
        $n = (Get-ChildItem $ThuAnh -File).Count
        Write-Host "  Day $n anh..."
        Adb push "$ThuAnh\." "$ThuMucWeb/anh-san-pham/" 2>&1 | Select-Object -Last 1 | Write-Host
    }
    if (Test-Path $ThuBieuCam) {
        $n = (Get-ChildItem $ThuBieuCam -File).Count
        Write-Host "  Day $n clip bieu cam..."
        Adb push "$ThuBieuCam\." "$ThuMucWeb/bieu-cam/" 2>&1 | Select-Object -Last 1 | Write-Host
    }
    if (Test-Path $ThuVideo) {
        $v = Get-ChildItem $ThuVideo -File
        $mb = [math]::Round(($v | Measure-Object Length -Sum).Sum / 1MB, 0)
        Write-Host "  Day $($v.Count) video ($mb MB) - cho vai phut, DUNG TAT MAY."
        Write-Host "  Mat mang giua chung thi chay lai lenh nay, tep da day xong duoc bo qua."
        Adb push "$ThuVideo\." "$ThuMucWeb/video/" 2>&1 | Select-Object -Last 1 | Write-Host
    }
    Xong "Xong giao dien"
}

# ══════════════ 4. Giong doc ══════════════
if ($LamHet -or $ChiGiong) {
    Buoc 4 "Day file giong doc"
    if (-not (Test-Path $ThuGiongPC)) {
        Nhac "Khong thay thu muc giong - ROBOT SE IM LANG HOAN TOAN."
        Nhac $MachGiong
    } else {
        $mp3 = Get-ChildItem $ThuGiongPC -Filter *.mp3
        if ($mp3.Count -eq 0) {
            Nhac "Thu muc giong rong - ROBOT SE IM LANG."
            Nhac $MachGiong
        } else {
            $mb = [math]::Round(($mp3 | Measure-Object Length -Sum).Sum / 1MB, 1)
            Write-Host "  Day $($mp3.Count) file MP3 ($mb MB)..."
            Adb shell "mkdir -p $ThuMucGiong" | Out-Null
            Adb push "$ThuGiongPC\." "$ThuMucGiong/" 2>&1 | Select-Object -Last 1 | Write-Host
            Xong "Xong giong doc"
        }
    }
}

# ══════════════ 5. Cau hinh Telegram ══════════════
if ($LamHet -or $ChiCauHinh) {
    Buoc 5 "Day cau hinh Telegram"
    if (-not (Test-Path $Tele)) {
        Nhac "Chua co telegram.json - KHACH DE LAI SO DIEN THOAI SE KHONG BAO VE DAU."
        Nhac $MachTele
    } else {
        Adb shell "mkdir -p $ThuMucApp" | Out-Null
        Adb push $Tele "$ThuMucApp/telegram.json" | Write-Host
        Xong "Xong cau hinh"
    }
}

# ══════════════ 6. Kiem lai ══════════════
Buoc 6 "Kiem lai tren may"
$sa = (Adb shell "ls $ThuMucWeb/anh-san-pham 2>/dev/null | wc -l").Trim()
$sv = (Adb shell "ls $ThuMucWeb/video 2>/dev/null | wc -l").Trim()
$sb = (Adb shell "ls $ThuMucWeb/bieu-cam 2>/dev/null | wc -l").Trim()
$sg = (Adb shell "ls $ThuMucGiong 2>/dev/null | wc -l").Trim()
Write-Host "  Anh: $sa | Video SP: $sv | Bieu cam: $sb | Giong: $sg"

Write-Host @"

================================================================
BON VIEC PHAI LAM TREN ROBOT - khong lam thi app chay nua voi
================================================================

1. DAT DIEM TREN BAN DO - 14 diem, ten phai TRUNG TUNG KY TU:

     Diem 1  Diem 2  Diem 3  Diem 4  Diem 5      <- robot di vong chao khach
     Vi tri 1 ... Vi tri 8                        <- 8 vi tri gian hang trong khu A12
     Diem Xuat Phat                               <- PIN DUOI 15% ROBOT TU VE DAY

   KHONG dau tieng Viet. Vao bang: Cai dat -> Cai dat ban do -> Chinh sua ban do
   Man nay HOI MAT KHAU ky thuat cua PUDU (xem PDF huong dan).

   !! THIEU "Diem Xuat Phat" thi robot chay toi khi CAN PIN giua loi di.

2. CHON MO-DUN TU KHOI DONG:
   Cai dat -> Chuc nang robot -> Cai dat mo-dun -> Chon mo-dun tu khoi dong
   -> chon "Hoi cho Tay Ninh".
   Tra robot ve cu: chon lai "Giao hang" o dung man do.

3. DINH VI LAI. Sau moi lan khoi dong robot dung o man "Dinh vi lai" - day la
   cong cua hang, khong lien quan app. DUNG BAM khi robot dang dung sai cho:
   no tu nhan dang o diem goc ban do roi co the chay di tim tram sac.

4. TU KIEM: bam giu goc DUOI TRAI man cho 1,5 giay -> man tu kiem.
   Xem du 14 diem chua, Telegram da noi chua, bo giong duoc bao nhieu cau.
   HOAC bam giu nut mo goc TREN TRAI -> "Kiem tra ban do".

Mo app: bam vao mo-dun tren man hinh chinh cua robot.
Ho tro: Roboworld 0866 153 946
"@ -ForegroundColor Cyan
