﻿# 采油厂油水井作业成本管理系统 - 一键启动脚本
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  采油厂油水井作业成本管理系统" -ForegroundColor Cyan
Write-Host "  正在启动服务..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 自动定位项目根目录：优先使用脚本所在目录，若失败则使用 E 盘默认路径
$defaultRoot = "E:\vue-code\数据库实践\mall-admin-web-master"
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "package.json"))) {
    $projectRoot = $PSScriptRoot
} elseif (Test-Path (Join-Path $defaultRoot "package.json")) {
    $projectRoot = $defaultRoot
} else {
    Write-Host "[错误] 未找到项目根目录，请确认脚本位置或 E 盘路径是否正确" -ForegroundColor Red
    Write-Host "  脚本目录: $PSScriptRoot" -ForegroundColor Gray
    Write-Host "  默认目录: $defaultRoot" -ForegroundColor Gray
    pause
    exit 1
}
$serverPath = Join-Path $projectRoot "server"
$logDir = Join-Path $projectRoot "logs"

Write-Host "[路径] 项目根目录: $projectRoot" -ForegroundColor Gray
Write-Host "[路径] 后端目录  : $serverPath" -ForegroundColor Gray
Write-Host ""

# 创建日志目录
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }

# ============== 前端 node_modules 检查与安装 ==============
$nodeModulesPath = Join-Path $projectRoot "node_modules"
if (-not (Test-Path $nodeModulesPath)) {
    Write-Host "[前端] 检测到 node_modules 不存在，正在执行 npm install..." -ForegroundColor Yellow
    Write-Host "[提示] 首次安装可能需要几分钟，请耐心等待" -ForegroundColor Gray
    Write-Host ""
    Push-Location $projectRoot
    npm install
    $installResult = $LASTEXITCODE
    Pop-Location
    if ($installResult -ne 0) {
        Write-Host ""
        Write-Host "[错误] npm install 失败，请检查网络或手动在项目目录执行 npm install" -ForegroundColor Red
        pause
        exit 1
    }
    Write-Host "[前端] 依赖安装完成" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "[前端] 依赖已安装 (node_modules 存在)" -ForegroundColor Green
}

# ============== 后端 node_modules 检查与安装 ==============
$serverNodeModules = Join-Path $serverPath "node_modules"
if (-not (Test-Path $serverNodeModules)) {
    Write-Host "[后端] 检测到 server/node_modules 不存在，正在执行 npm install..." -ForegroundColor Yellow
    Push-Location $serverPath
    npm install
    $serverInstallResult = $LASTEXITCODE
    Pop-Location
    if ($serverInstallResult -ne 0) {
        Write-Host "[错误] 后端依赖安装失败" -ForegroundColor Red
        pause
        exit 1
    }
    Write-Host "[后端] 依赖安装完成" -ForegroundColor Green
} else {
    Write-Host "[后端] 依赖已安装" -ForegroundColor Green
}

# ============== 启动后端 ==============
$backendRunning = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($backendRunning) {
    Write-Host "[后端] 服务已在运行 (端口 8080)" -ForegroundColor Yellow
} else {
    Write-Host "[后端] 正在启动后端服务..." -ForegroundColor Green
    $backendLog = Join-Path $logDir "backend.log"
    # 使用 cmd.exe 启动并把日志写入文件，避免窗口一闪而过看不到错误
    Start-Process cmd.exe -ArgumentList "/k", "cd /d `"$serverPath`" && title 后端服务 && node index.js > `"$backendLog`" 2>&1" -WindowStyle Normal
    Start-Sleep -Seconds 3
}

# ============== 启动前端 ==============
$frontendRunning = Get-NetTCPConnection -LocalPort 5173 -ErrorAction SilentlyContinue
if ($frontendRunning) {
    Write-Host "[前端] 服务已在运行 (端口 5173)" -ForegroundColor Yellow
} else {
    Write-Host "[前端] 正在启动前端服务..." -ForegroundColor Green
    $frontendLog = Join-Path $logDir "frontend.log"
    # 使用 cmd.exe 启动并把日志写入文件；--strictPort 强制使用 5173 端口
    Start-Process cmd.exe -ArgumentList "/k", "cd /d `"$projectRoot`" && title 前端服务 && npm run dev -- --port 5173 --strictPort --host 127.0.0.1 > `"$frontendLog`" 2>&1" -WindowStyle Normal
    Write-Host "[前端] 启动日志输出到: $frontendLog" -ForegroundColor Gray
    Start-Sleep -Seconds 8

    # 检查是否真的启动了
    $frontendCheck = Get-NetTCPConnection -LocalPort 5173 -ErrorAction SilentlyContinue
    if (-not $frontendCheck) {
        Write-Host "[警告] 前端服务未能启动，请查看日志: $frontendLog" -ForegroundColor Red
        Write-Host "[提示] 可手动执行: cd '$projectRoot' && npm run dev" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  服务启动完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  前端地址: http://localhost:5173" -ForegroundColor White
Write-Host "  后端地址: http://localhost:8080" -ForegroundColor White
Write-Host "  登录账号: admin" -ForegroundColor White
Write-Host "  登录密码: password" -ForegroundColor White
Write-Host "  日志目录: $logDir" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
pause
