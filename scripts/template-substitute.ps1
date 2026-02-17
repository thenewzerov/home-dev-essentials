param(
    [Parameter(Mandatory = $false)]
    [string]$RootPath = 'temp',

    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = 'configuration.cfg'
)

$ErrorActionPreference = 'Stop'

function Get-Trimmed([string]$value) {
    if ($null -eq $value) { return '' }
    return $value.Trim()
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "configuration file not found: $ConfigPath"
}

$config = @{}

Get-Content -LiteralPath $ConfigPath | ForEach-Object {
    $line = Get-Trimmed $_

    if ($line -eq '' -or $line.StartsWith('#')) {
        return
    }

    $colonIndex = $line.IndexOf(':')
    if ($colonIndex -lt 0) {
        return
    }

    $key = Get-Trimmed $line.Substring(0, $colonIndex)
    $value = Get-Trimmed $line.Substring($colonIndex + 1)

    if ($key -eq '') {
        return
    }

    $config[$key] = $value
}

$replacements = @{}

foreach ($key in $config.Keys) {
    $value = $config[$key]

    $replacements['${' + $key + '}'] = $value
    $replacements['%%' + $key + '%%'] = $value
}

# Back-compat: if legacy typo key exists, also publish corrected key placeholders
if ($config.ContainsKey('APPLICATIONS.ISTIO.GLOBAL.PLATOFORM') -and -not $config.ContainsKey('APPLICATIONS.ISTIO.GLOBAL.PLATFORM')) {
    $legacy = $config['APPLICATIONS.ISTIO.GLOBAL.PLATOFORM']
    $replacements['${APPLICATIONS.ISTIO.GLOBAL.PLATFORM}'] = $legacy
    $replacements['%%APPLICATIONS.ISTIO.GLOBAL.PLATFORM%%'] = $legacy
}

# Derived variables: treat blank as 'none'
$platform = ''
if ($config.ContainsKey('APPLICATIONS.ISTIO.GLOBAL.PLATFORM')) {
    $platform = Get-Trimmed $config['APPLICATIONS.ISTIO.GLOBAL.PLATFORM']
} elseif ($config.ContainsKey('APPLICATIONS.ISTIO.GLOBAL.PLATOFORM')) {
    $platform = Get-Trimmed $config['APPLICATIONS.ISTIO.GLOBAL.PLATOFORM']
}

$platformSetArg = ''
if ($platform -ne '' -and $platform.ToLowerInvariant() -ne 'none') {
    $platformSetArg = '--set global.platform=' + $platform
}

$replacements['${APPLICATIONS.ISTIO.GLOBAL.PLATFORM.SETARG}'] = $platformSetArg
$replacements['%%APPLICATIONS.ISTIO.GLOBAL.PLATFORM.SETARG%%'] = $platformSetArg

$cniChained = ''
if ($config.ContainsKey('APPLICATIONS.ISTIO.CNI.CHAINED')) {
    $cniChained = Get-Trimmed $config['APPLICATIONS.ISTIO.CNI.CHAINED']
}

$cniChainedSetArg = ''
if ($cniChained -ne '' -and $cniChained.ToLowerInvariant() -ne 'none') {
    $cniChainedSetArg = '--set chained=' + $cniChained
}

$replacements['${APPLICATIONS.ISTIO.CNI.CHAINED.SETARG}'] = $cniChainedSetArg
$replacements['%%APPLICATIONS.ISTIO.CNI.CHAINED.SETARG%%'] = $cniChainedSetArg

$ambient = ''
if ($config.ContainsKey('APPLICATIONS.ISTIO.AMBIENT')) {
    $ambient = Get-Trimmed $config['APPLICATIONS.ISTIO.AMBIENT']
}

$ambientEnabled = $ambient.ToLowerInvariant() -eq 'true'

$ambientIstiodSetArg = ''
$ambientZtunnelCommand = ''

if ($ambientEnabled) {
    $ambientIstiodSetArg = '--set profile=ambient'

    # Install ztunnel when ambient mode is enabled.
    # Note: This uses the already-derived platform setarg to match the rest of Istio installs.
    $ambientZtunnelCommand = ('helm upgrade --install ztunnel istio/ztunnel -n istio-system ' + $platformSetArg + ' --wait').Trim()
}

$replacements['${APPLICATIONS.ISTIO.AMBIENT.ISTIOD.SETARG}'] = $ambientIstiodSetArg
$replacements['%%APPLICATIONS.ISTIO.AMBIENT.ISTIOD.SETARG%%'] = $ambientIstiodSetArg
$replacements['${APPLICATIONS.ISTIO.AMBIENT.ZTUNNEL.COMMAND}'] = $ambientZtunnelCommand
$replacements['%%APPLICATIONS.ISTIO.AMBIENT.ZTUNNEL.COMMAND%%'] = $ambientZtunnelCommand

Get-ChildItem -LiteralPath $RootPath -Recurse -File | ForEach-Object {
    try {
        $content = Get-Content -LiteralPath $_.FullName -Raw -ErrorAction Stop
        $modified = $content

        foreach ($k in $replacements.Keys) {
            $modified = $modified.Replace($k, $replacements[$k])
        }

        if ($modified -ne $content) {
            Set-Content -LiteralPath $_.FullName -Value $modified -NoNewline
        }
    } catch {
        # Intentionally ignore unreadable/binary files
    }
}
