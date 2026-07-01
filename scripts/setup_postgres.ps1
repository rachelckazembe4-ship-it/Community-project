$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$backend = Join-Path $root "backend"

$env:POSTGRES_DB = if ($env:POSTGRES_DB) { $env:POSTGRES_DB } else { "community_project" }
$env:POSTGRES_USER = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { "postgres" }
$env:POSTGRES_PASSWORD = if ($env:POSTGRES_PASSWORD) { $env:POSTGRES_PASSWORD } else { "postgres" }
$env:POSTGRES_HOST = if ($env:POSTGRES_HOST) { $env:POSTGRES_HOST } else { "localhost" }
$env:POSTGRES_PORT = if ($env:POSTGRES_PORT) { $env:POSTGRES_PORT } else { "5432" }

function Test-PostgresPort {
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $async = $client.BeginConnect($env:POSTGRES_HOST, [int]$env:POSTGRES_PORT, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne(1000)) {
            return $false
        }
        $client.EndConnect($async)
        return $true
    }
    catch {
        return $false
    }
    finally {
        $client.Close()
    }
}

if (-not (Test-PostgresPort)) {
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if ($docker) {
        Write-Host "Starting Postgres with Docker Compose..."
        Push-Location $root
        docker compose up -d postgres
        Pop-Location

        for ($i = 0; $i -lt 30; $i++) {
            if (Test-PostgresPort) {
                break
            }
            Start-Sleep -Seconds 1
        }
    }
}

if (-not (Test-PostgresPort)) {
    Write-Host "Postgres is not reachable at $($env:POSTGRES_HOST):$($env:POSTGRES_PORT)."
    Write-Host "Install Docker Desktop or PostgreSQL, then run this script again."
    exit 1
}

$createdb = Get-Command createdb -ErrorAction SilentlyContinue
if ($createdb) {
    Write-Host "Ensuring database '$($env:POSTGRES_DB)' exists..."
    $env:PGPASSWORD = $env:POSTGRES_PASSWORD
    createdb -h $env:POSTGRES_HOST -p $env:POSTGRES_PORT -U $env:POSTGRES_USER $env:POSTGRES_DB 2>$null
}

Write-Host "Installing Python dependencies..."
Push-Location $backend
pip install -r requirements.txt

Write-Host "Running migrations..."
python manage.py migrate

Write-Host "Seeding sample data..."
python seed_data.py

Write-Host "Done. Start the backend with:"
Write-Host "  python manage.py runserver"
Pop-Location
