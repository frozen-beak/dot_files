# -----------------------------------
# ---------- ENV Variables ----------
# -----------------------------------


$ENV:STARSHIP_CONFIG = "$HOME\.config\starship.toml"


# -----------------------------------
# ---------- Apps Launcher ----------
# -----------------------------------


$apps = @{
    'br' = @{
        'default' = @(
            'C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe', '--profile-directory="Profile 2"'
        )
        'p'       = @(
            'C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe', '--profile-directory="Default"'
        )
        'fb'      = @(
            'C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe', '--profile-directory="Profile 1"'
        )
        'e'       = @(
            'C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe', '--profile-directory="Profile 3"'
        )
        'a'       = @(
            'C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe', '--profile-directory="Profile 4"'
        )
        'ui'      = @(
            'C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe', '--profile-directory="Profile 6"'
        )
    }
}

function run {
    param (
        [Alias("app")]
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$appName,

        [Parameter(Position = 1, Mandatory = $false)]
        [string]$id = 'default'
    )

    if ($id.StartsWith("--")) {
        $id = $id.Substring(2)
    }

    if ($apps.ContainsKey($appName)) {
        $app = $apps[$appName] 

        if ($app.ContainsKey($id)) {
            $command = $app[$id]
            & $command[0] $command[1..($command.Length - 1)]

            Clear-Host
        }
        else {
            Write-Host "[ERR] Profile '$id' not found for $appName."
        }
    }
    else {
        Write-Host "[ERR] App '$appName' not found."
    }
}


# ------------------------------------
# ---------- Custom Actions ----------
# ------------------------------------


function yeet {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path -Path $Path) {
        try {
            if ((Get-Item -Path $Path).PSIsContainer) {
                Remove-Item -Path $Path -Recurse -Force
                Write-Host "Trashed -> $Path" -ForegroundColor Green
            }
            else {
                Remove-Item -Path $Path -Force
                Write-Host "Trashed -> $Path"  -ForegroundColor Green
            }
        }
        catch {
            Write-Host "[ERR] 500: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "[ERR] 404: $Path" -ForegroundColor Yellow
    }
}

function touch {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    try {
        New-Item -ItemType File -Path $FilePath -Force | Out-Null
        Write-Host "Created -> $FilePath" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERR] 500: $_" -ForegroundColor Red
    }
}

function set-light {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, 100)]
        [int]$Level
    )
    try {
        (Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1, $Level)
        Write-Host "Brightness -> $Level%" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERR] 500: $_" -ForegroundColor Red
    }
}

function stop {
    Stop-Computer
}

function restart {
    Restart-Computer
}

function signout {
    shutdown /l
}

function shut {
    Add-Type -AssemblyName System.Windows.Forms
    $PowerState = [System.Windows.Forms.PowerState]::Suspend
    $Force = $false
    $DisableWake = $false
    [System.Windows.Forms.Application]::SetSuspendState($PowerState, $Force, $DisableWake)
}


# ---------------------------
# ---------- Help -----------
# ---------------------------


function help {
    $customCommands = @{
        'run'       = @{
            syntax      = 'run [-appName] <string> [-id <string>]'
            description = 'Launch applications with specific profiles'
            parameters  = @(
                'appName: Application short name (e.g., br)',
                'id: Profile ID (default: "default")'
            )
        }
        'yeet'      = @{
            syntax      = 'yeet -Path <string>'
            description = 'Force delete files/folders'
        }
        'touch'     = @{
            syntax      = 'touch -FilePath <string>'
            description = 'Create new empty file'
        }
        'set-light' = @{
            syntax      = 'set-light -Level <0-100>'
            description = 'Set screen brightness level'
        }
        'stop'      = @{
            syntax      = 'stop'
            description = 'Shutdown computer'
        }
        'restart'   = @{
            syntax      = 'restart'
            description = 'Restart computer'
        }
        'signout'   = @{
            syntax      = 'signout'
            description = 'Sign out current user'
        }
        'shut'      = @{
            syntax      = 'shut'
            description = 'Put computer to sleep'
        }
    }

    Write-Host "`nAvailable Commands`n" -ForegroundColor Cyan

    foreach ($cmd in $customCommands.Keys) {
        Write-Host "Command: $($cmd.ToUpper())" -ForegroundColor Green

        Write-Host "  Syntax: $($customCommands[$cmd].syntax)"
        Write-Host "  Desc: $($customCommands[$cmd].description)"

        if ($customCommands[$cmd].parameters) {
            Write-Host "  Params:"
            $customCommands[$cmd].parameters | ForEach-Object {
                Write-Host "    - $_"
            }
        }

        Write-Host ""
    }
}


# -----------------------------------
# ---------- AutoComplete -----------
# -----------------------------------


Register-ArgumentCompleter -CommandName run -ParameterName appName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $apps = (Get-Variable -Scope 1 -Name apps).Value
    $apps.Keys | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -CommandName run -ParameterName id -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $apps = (Get-Variable -Scope 1 -Name apps).Value
    $appName = $fakeBoundParameter['appName']
    
    if (-not $appName) {
        $appName = $fakeBoundParameter['app']  
    }

    if ($appName -and $apps.ContainsKey($appName)) {
        $apps[$appName].Keys | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}


# -------------------------------------
# ---------- Default Actions ----------
# -------------------------------------


Invoke-Expression (&starship init powershell)
Import-Module -Name Terminal-Icons


# -------------------------------------
# ---------- Default Actions ----------
# -------------------------------------


Invoke-Expression (&starship init powershell)
Import-Module -Name Terminal-Icons
