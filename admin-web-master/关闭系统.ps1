﻿﻿﻿﻿﻿# 采油厂油水井作业成本管理系统 - 一键关闭脚本
# 用法:右键 PowerShell 运行 / 双击 / 在 PowerShell 中执行 .ps1 文件

# 设置控制台编码,防止中文乱码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 解决双击运行时的执行策略问题(仅对当前进程生效)
try {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction SilentlyContinue
} catch {}

function Stop-ByPort {
    param([int]$Port, [string]$Label)
    Write-Host "[$Label] 正在关闭端口 $Port 上的服务..." -ForegroundColor Yellow
    $procIds = @()

    # 方法 1:Get-NetTCPConnection(需 Win8+ / Server 2012+)
    try {
        $conn = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop
        if ($conn) { $procIds += $conn | Select-Object -ExpandProperty OwningProcess -Unique }
    } catch {}

    # 方法 2:netstat 兜底
    if (-not $procIds) {
        try {
            $netstatOut = netstat -ano -p TCP 2>$null
            $lines = $netstatOut | Select-String ":$Port\s"
            foreach ($line in $lines) {
                $parts = ($line -replace '\s+', ' ').Trim().Split(' ')
                if ($parts.Count -ge 5) { $procIds += [int]$parts[-1] }
            }
            $procIds = $procIds | Sort-Object -Unique
        } catch {}
    }

    if ($procIds) {
        foreach ($procId in $procIds) {
            try {
                Stop-Process -Id $procId -Force -ErrorAction Stop
                Write-Host "  已终止 PID: $procId" -ForegroundColor Green
            } catch {
                Write-Host "  终止 PID $procId 失败: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "  端口 $Port 无服务在运行" -ForegroundColor Gray
    }
}

function Stop-ProjectNode {
    param([string]$RootPath, [string]$ProjectName)
    Write-Host "[清理] 检查项目残留 node 进程..." -ForegroundColor Yellow
    $killed = 0
    try {
        $procs = Get-CimInstance Win32_Process -Filter "Name = 'node.exe'" -ErrorAction Stop
        foreach ($p in $procs) {
            $cmd = "$($p.CommandLine)"
            if ($cmd -and ($cmd -like "*$ProjectName*" -or $cmd -like "*$RootPath*")) {
                try {
                    Stop-Process -Id $p.ProcessId -Force -ErrorAction Stop
                    Write-Host "  已清理 node 进程 PID: $($p.ProcessId)" -ForegroundColor Green
                    $killed++
                } catch {
                    Write-Host "  清理 PID $($p.ProcessId) 失败: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    } catch {
        # 兜底:用 Get-Process
        try {
            $procs = Get-Process -Name "node" -ErrorAction SilentlyContinue
            foreach ($p in $procs) {
                try {
                    $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId = $($p.Id)" -ErrorAction Stop).CommandLine
                } catch { $cmd = "" }
                if ($cmd -and ($cmd -like "*$ProjectName*" -or $cmd -like "*$RootPath*")) {
                    Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
                    Write-Host "  已清理 node 进程 PID: $($p.Id)" -ForegroundColor Green
                    $killed++
                }
            }
        } catch {}
    }
    if ($killed -eq 0) { Write-Host "  无残留 node 进程" -ForegroundColor Gray }
}

function Stop-NpmProcesses {
    Write-Host "[清理] 检查 npm/cmd 残留进程..." -ForegroundColor Yellow
    $killed = 0
    foreach ($name in @("npm", "npm.cmd", "cmd")) {
        try {
            $procs = Get-CimInstance Win32_Process -Filter "Name = '$name.exe'" -ErrorAction Stop
            foreach ($p in $procs) {
                $cmd = "$($p.CommandLine)"
                if ($cmd -and ($cmd -like "*mall-admin-web*" -or $cmd -like "*vite*")) {
                    try {
                        Stop-Process -Id $p.ProcessId -Force -ErrorAction Stop
                        Write-Host "  已清理 $name 进程 PID: $($p.ProcessId)" -ForegroundColor Green
                        $killed++
                    } catch {}
                }
            }
        } catch {}
    }
    if ($killed -eq 0) { Write-Host "  无残留 npm/cmd 进程" -ForegroundColor Gray }
}

# ============== 主流程 ==============
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  采油厂油水井作业成本管理系统" -ForegroundColor Cyan
Write-Host "  正在关闭服务..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 自动定位项目根目录
$defaultRoot = "E:\vue-code\数据库实践\mall-admin-web-master"
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "package.json"))) {
    $projectRoot = $PSScriptRoot
} elseif (Test-Path (Join-Path $defaultRoot "package.json")) {
    $projectRoot = $defaultRoot
} else {
    $projectRoot = $defaultRoot
}
$projectName = Split-Path -Leaf $projectRoot
Write-Host "[路径] 项目根目录: $projectRoot" -ForegroundColor Gray
Write-Host "[名称] 项目目录名: $projectName" -ForegroundColor Gray
Write-Host ""

# 关闭后端 (8080)
Stop-ByPort -Port 8080 -Label "后端"
Write-Host ""

# 关闭前端 (5173)
Stop-ByPort -Port 5173 -Label "前端"
Write-Host ""

# 关闭残留 node 进程
Stop-ProjectNode -RootPath $projectRoot -ProjectName $projectName
Write-Host ""

# 关闭 npm/cmd 残留
Stop-NpmProcesses
Write-Host ""

# 二次验证端口
Write-Host "[验证] 二次检查端口状态..." -ForegroundColor Yellow
foreach ($p in @(8080, 5173)) {
    $still = @()
    try {
        $still = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue
    } catch {}
    if ($still) {
        Write-Host "  端口 $p 仍有进程占用" -ForegroundColor Red
        $still | ForEach-Object { Write-Host "    PID: $($_.OwningProcess)" -ForegroundColor Red }
    } else {
        Write-Host "  端口 $p 已释放" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  所有服务已关闭!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
pause