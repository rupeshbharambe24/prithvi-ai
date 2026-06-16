<#
    PRITHVI-AI — full weekly pipeline runner
    --------------------------------------------------------------------
    Run this every Friday 11 PM (double-click run_weekly.bat, or:
        powershell -ExecutionPolicy Bypass -File .\run_weekly.ps1 )

    It runs the complete cycle:
      1) DAILY : ingest latest data -> score matured forecasts vs actuals
                 -> refresh forward forecasts -> drift check
      2) WEEKLY: retrain all models -> champion/challenger promote
                 -> backtest -> fairness -> refresh forecasts

    Results show up in the web console:
      * Models page    -> model performance & active champion per target
      * Fairness & QA  -> drift (PSI) & per-region fairness gaps

    Output is shown live and saved to .\pipeline-logs\pipeline_<timestamp>.log
#>

$Root    = Split-Path -Parent $MyInvocation.MyCommand.Path
$Backend = Join-Path $Root 'backend'
$Python  = Join-Path $Root 'prithvi-ai\Scripts\python.exe'
$LogDir  = Join-Path $Root 'pipeline-logs'
$Stamp   = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$Log     = Join-Path $LogDir "pipeline_$Stamp.log"

if (-not (Test-Path $Python)) {
    Write-Host "ERROR: venv Python not found at $Python" -ForegroundColor Red
    Write-Host "Recreate the venv:  python -m venv prithvi-ai" -ForegroundColor Yellow
    exit 1
}
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

Start-Transcript -Path $Log -Append | Out-Null

Write-Host "============================================================" -ForegroundColor Yellow
Write-Host "  PRITHVI-AI pipeline run : $Stamp"
Write-Host "  Log file               : $Log"
Write-Host "============================================================" -ForegroundColor Yellow

Set-Location $Backend

Write-Host "`n[1/2] DAILY  : ingest + score + refresh forecasts + drift ..." -ForegroundColor Cyan
& $Python -m backend.app.scripts.run_pipeline daily
$daily = $LASTEXITCODE

Write-Host "`n[2/2] WEEKLY : retrain + champion/challenger + backtest + fairness ..." -ForegroundColor Cyan
& $Python -m backend.app.scripts.run_pipeline weekly
$weekly = $LASTEXITCODE

Write-Host "`n============================================================" -ForegroundColor Yellow
if ($daily -eq 0 -and $weekly -eq 0) {
    Write-Host "  SUCCESS - pipeline complete." -ForegroundColor Green
    Write-Host "  Open the console to view results:"
    Write-Host "    * Models page   -> performance & active champion models"
    Write-Host "    * Fairness & QA -> drift (PSI) & fairness gaps"
} else {
    Write-Host "  ONE OR MORE STAGES FAILED (daily=$daily weekly=$weekly)." -ForegroundColor Red
    Write-Host "  See the log for details: $Log" -ForegroundColor Yellow
}
Write-Host "============================================================" -ForegroundColor Yellow

Stop-Transcript | Out-Null
