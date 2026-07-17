<#
.SYNOPSIS
  vscode-connect.ps1 — Windows 클라이언트의 Claude Code(CLI·VSCode 확장)를 LMS 서버에 직결/해제.
  (4.lms_OneLLM Windows 클라이언트 패치 — vscode-connect.sh 의 PowerShell 판, jq 불필요)

.DESCRIPTION
  Windows 의 Claude Code(CLI·VSCode 확장)는 %USERPROFILE%\.claude\settings.json 을 읽는다.
  이 스크립트는 그 파일에 아래를 "병합"(기존 키 보존)한다:
    env.ANTHROPIC_BASE_URL   = http://<LmsHost>:<Port>
    env.ANTHROPIC_AUTH_TOKEN = lms
    env.API_TIMEOUT_MS       = 600000   (느린 로컬 추론 대비)
    env.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1
    model                    = <Model>

  전제: LMS 가 도는 리눅스 호스트의 .env 에서 LMS_BIND_HOST=0.0.0.0 으로 포트가
        LAN 에 publish 되어 있어야 함 (PATCH.md 참조). 방화벽에서 <Port> 허용 필요.

.EXAMPLE
  .\vscode-connect.ps1 on -LmsHost 192.168.0.4 -Model meta-llama-3.1-8b-instruct
  .\vscode-connect.ps1 status -LmsHost 192.168.0.4
  .\vscode-connect.ps1 off -Model meta-llama-3.1-8b-instruct

.NOTES
  ⚠️ 전역 설정을 바꾸므로 이 Windows 머신의 모든 Claude Code(CLI+확장)가 LMS 로 향한다.
     실제 Anthropic 로 되돌리려면 'off'. 적용 후 VSCode 'Developer: Reload Window'.
  실행 정책 오류 시: powershell -ExecutionPolicy Bypass -File .\vscode-connect.ps1 on ...
#>
[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [ValidateSet('on', 'off', 'status')]
  [string]$Action = 'on',

  # LMS 서버(리눅스 docker 호스트) IP/호스트명. env LMS_HOST 로도 지정 가능.
  [string]$LmsHost = $(if ($env:LMS_HOST) { $env:LMS_HOST } else { '127.0.0.1' }),

  [int]$Port = $(if ($env:LMS_PORT) { [int]$env:LMS_PORT } else { 1234 }),

  # LMS 에 로드된 모델 키 (.env 의 LMS_MODEL 과 동일해야 함)
  [string]$Model = $env:LMS_MODEL,

  [string]$TimeoutMs = $(if ($env:API_TIMEOUT_MS) { $env:API_TIMEOUT_MS } else { '600000' }),

  # 대상 settings.json (기본: 전역. 워크스페이스에만 적용하려면 .claude\settings.local.json 지정)
  [string]$SettingsPath = $(if ($env:CLAUDE_SETTINGS) { $env:CLAUDE_SETTINGS }
                            else { Join-Path $env:USERPROFILE '.claude\settings.json' })
)

$ErrorActionPreference = 'Stop'
$BaseUrl = "http://${LmsHost}:${Port}"

function Read-Settings {
  if ((Test-Path $SettingsPath) -and (Get-Content $SettingsPath -Raw).Trim()) {
    return (Get-Content $SettingsPath -Raw | ConvertFrom-Json)
  }
  return [pscustomobject]@{}
}

function Write-Settings($obj) {
  $dir = Split-Path $SettingsPath -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  # UTF-8 (BOM 없음) — Set-Content -Encoding UTF8 은 PS5.1 에서 BOM 을 붙여 파서 문제 소지
  [System.IO.File]::WriteAllText($SettingsPath, ($obj | ConvertTo-Json -Depth 10),
    (New-Object System.Text.UTF8Encoding($false)))
}

function Test-Lms {
  try {
    $null = Invoke-RestMethod -Uri "$BaseUrl/v1/models" -TimeoutSec 5
    return $true
  } catch { return $false }
}

switch ($Action) {
  'on' {
    if (Test-Lms) {
      Write-Host "[+] LMS 응답 OK: $BaseUrl/v1/models"
    } else {
      Write-Host "[!] LMS 무응답($BaseUrl) — 서버 기동·LMS_BIND_HOST=0.0.0.0·방화벽 확인. (계속 진행)"
    }
    if (-not $Model) { Write-Host "[!] -Model (또는 env LMS_MODEL) 필요"; exit 1 }

    $settings = Read-Settings

    # 최초 1회 백업
    $bak = "$SettingsPath.bak"
    if ((Test-Path $SettingsPath) -and -not (Test-Path $bak)) {
      Copy-Item $SettingsPath $bak
      Write-Host "[+] 백업: $bak"
    }

    if (-not ($settings.PSObject.Properties.Name -contains 'env') -or $null -eq $settings.env) {
      $settings | Add-Member -NotePropertyName env -NotePropertyValue ([pscustomobject]@{}) -Force
    }
    $settings.env | Add-Member -NotePropertyName ANTHROPIC_BASE_URL   -NotePropertyValue $BaseUrl -Force
    $settings.env | Add-Member -NotePropertyName ANTHROPIC_AUTH_TOKEN -NotePropertyValue 'lms' -Force
    $settings.env | Add-Member -NotePropertyName API_TIMEOUT_MS       -NotePropertyValue $TimeoutMs -Force
    $settings.env | Add-Member -NotePropertyName CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC -NotePropertyValue '1' -Force
    $settings | Add-Member -NotePropertyName model -NotePropertyValue $Model -Force
    Write-Settings $settings

    Write-Host "[+] 연결 설정 완료 → $SettingsPath"
    Write-Host "      ANTHROPIC_BASE_URL = $BaseUrl"
    Write-Host "      model              = $Model"
    Write-Host "      API_TIMEOUT_MS     = $TimeoutMs  (느린 로컬 추론 대비)"
    Write-Host "      CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1"
    Write-Host ''
    Write-Host "  다음: VSCode 명령팔레트 → 'Developer: Reload Window' (또는 확장 재시작)"
  }

  'off' {
    $settings = Read-Settings
    if ($settings.PSObject.Properties.Name -contains 'env' -and $null -ne $settings.env) {
      foreach ($k in 'ANTHROPIC_BASE_URL', 'ANTHROPIC_AUTH_TOKEN', 'API_TIMEOUT_MS',
                     'CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC') {
        $settings.env.PSObject.Properties.Remove($k)
      }
      if ($settings.env.PSObject.Properties.Count -eq 0) {
        $settings.PSObject.Properties.Remove('env')
      }
    }
    if ($Model -and $settings.model -eq $Model) {
      $settings.PSObject.Properties.Remove('model')
    }
    Write-Settings $settings
    Write-Host "[+] 연결 해제(우리가 넣은 키 제거) → $SettingsPath"
    Write-Host "      (전체 복원이 필요하면: Copy-Item $SettingsPath.bak $SettingsPath)"
    Write-Host "  다음: VSCode 'Developer: Reload Window'"
  }

  'status' {
    Write-Host "대상: $SettingsPath"
    $settings = Read-Settings
    [pscustomobject]@{
      model = $settings.model
      env   = if ($settings.env) {
                $settings.env | Select-Object ANTHROPIC_BASE_URL, ANTHROPIC_AUTH_TOKEN,
                                              API_TIMEOUT_MS, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
              } else { $null }
    } | ConvertTo-Json -Depth 5 | Write-Host
    Write-Host "LMS($BaseUrl) 응답:"
    try {
      (Invoke-RestMethod -Uri "$BaseUrl/v1/models" -TimeoutSec 5).data |
        ForEach-Object { Write-Host "  - $($_.id)" }
    } catch {
      Write-Host '  (무응답)'
    }
  }
}
