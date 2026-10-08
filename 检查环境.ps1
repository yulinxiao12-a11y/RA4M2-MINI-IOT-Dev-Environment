param(
    [string] $SoftwareRoot = ''
)

$ErrorActionPreference = 'Stop'
$installers = Join-Path $PSScriptRoot '安装文件'
$expected = @(
    [pscustomobject]@{
        Name = 'setup_fsp_v6_4_0_e2s_v2025-12.exe'
        Sha256 = 'D6CDCD1A3F022BB708E97F7DF992A70057AE77247B730A02FACAA0B5EF6BCC59'
    },
    [pscustomobject]@{
        Name = 'FSP_Packs_v5.9.0.exe'
        Sha256 = '9B0B9D264929F542394CB732F350E72B68864E7143F739A5A109F1D17109407C'
    }
)

Write-Host "安装文件目录: $installers"
$allValid = $true
foreach ($item in $expected) {
    $path = Join-Path $installers $item.Name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Write-Host "[缺失] $($item.Name)" -ForegroundColor Red
        $allValid = $false
        continue
    }

    $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash
    $signature = Get-AuthenticodeSignature -LiteralPath $path
    $hashOk = $actual -eq $item.Sha256
    $signatureOk = $signature.Status -eq 'Valid' -and
        $signature.SignerCertificate.Subject -like '*Renesas Electronics Corporation*'
    $status = if ($hashOk -and $signatureOk) { '通过' } else { '失败' }
    Write-Host "[$status] $($item.Name) SHA-256=$actual; 签名=$($signature.Status)"
    if (-not ($hashOk -and $signatureOk)) { $allValid = $false }
}

if ([string]::IsNullOrWhiteSpace($SoftwareRoot)) {
    Write-Host '[跳过] 未指定软件安装根目录；安装后可用 -SoftwareRoot 传入安装向导中的 e² studio 根目录。' -ForegroundColor Yellow
    if (-not $allValid) { exit 1 }
    exit 0
}

Write-Host "软件安装根目录: $SoftwareRoot"
if (-not (Test-Path -LiteralPath $SoftwareRoot -PathType Container)) {
    Write-Host '[未发现] 指定的安装根目录；请传入安装向导中选择的 e² studio 根目录。' -ForegroundColor Yellow
    exit 1
}

$softwareValid = $true
$ide = Get-ChildItem -LiteralPath $SoftwareRoot -Filter 'e2studio.exe' -File -Recurse -ErrorAction SilentlyContinue |
    Select-Object -First 1
if ($ide) {
    Write-Host "[发现] e2 studio: $($ide.FullName)"
    $eclipseDir = $ide.Directory.FullName
    $installRoot = $ide.Directory.Parent.FullName
    $configIni = Join-Path $eclipseDir 'configuration\config.ini'
    if (Test-Path -LiteralPath $configIni -PathType Leaf) {
        $release = (Select-String -Path $configIni -Pattern '^e2studio\.release=(.+)$' | Select-Object -First 1).Matches.Groups[1].Value
        $buildId = (Select-String -Path $configIni -Pattern '^eclipse\.buildId=(.+)$' | Select-Object -First 1).Matches.Groups[1].Value
        Write-Host "        发布版: $release; 构建号: $buildId"
    }

    $fspDocs = Join-Path $installRoot 'fsp_documentation'
    $fsp59 = $false
    if (Test-Path -LiteralPath $fspDocs -PathType Container) {
        $fspVersions = Get-ChildItem -LiteralPath $fspDocs -Directory | ForEach-Object { $_.Name -replace '^v', '' }
        Write-Host "        已安装 FSP 包: $($fspVersions -join ', ')"
        $fsp59 = Test-Path -LiteralPath (Join-Path $fspDocs 'v5.9.0') -PathType Container
    }
    if ($fsp59) {
        Write-Host '[发现] FSP 5.9.0'
    } else {
        Write-Host '[未发现] FSP 5.9.0；运行 FSP_Packs_v5.9.0.exe 并选择此 e² studio 根目录。' -ForegroundColor Yellow
        $softwareValid = $false
    }
} else {
    Write-Host '[未发现] e2studio.exe' -ForegroundColor Yellow
    $softwareValid = $false
}

$gcc = Get-ChildItem -LiteralPath $SoftwareRoot -Filter 'arm-none-eabi-gcc.exe' -File -Recurse -ErrorAction SilentlyContinue |
    Select-Object -First 1
if ($gcc) {
    Write-Host "[发现] Arm GNU: $($gcc.FullName)"
    & $gcc.FullName --version | Select-Object -First 1
} else {
    Write-Host '[未发现] arm-none-eabi-gcc.exe' -ForegroundColor Yellow
    $softwareValid = $false
}

Write-Host '工程 configuration.xml 的 Summary 页面仍需核对目标工程实际使用的 FSP 版本。'
if (-not $allValid -or -not $softwareValid) { exit 1 }
