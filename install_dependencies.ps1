# JModelica C++ Dependencies Installation Script
# This script installs Ipopt and Sundials, builds C++ extensions, and tests examples

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "JModelica C++ Dependencies Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Install Ipopt
Write-Host "[1/5] Installing Ipopt (this will take 30-60 minutes)..." -ForegroundColor Yellow
C:\vcpkg_official\vcpkg.exe install ipopt --triplet x64-windows --clean-after-build
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Ipopt installation failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Ipopt installed successfully" -ForegroundColor Green
Write-Host ""

# Step 2: Install Sundials
Write-Host "[2/5] Installing Sundials (this will take 15-30 minutes)..." -ForegroundColor Yellow
C:\vcpkg_official\vcpkg.exe install sundials --triplet x64-windows --clean-after-build
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Sundials installation failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Sundials installed successfully" -ForegroundColor Green
Write-Host ""

# Step 3: Configure CMake
Write-Host "[3/5] Configuring CMake with vcpkg toolchain..." -ForegroundColor Yellow
$vcpkgToolchain = "C:\vcpkg_official\scripts\buildsystems\vcpkg.cmake"
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=$vcpkgToolchain
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: CMake configuration failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ CMake configured successfully" -ForegroundColor Green
Write-Host ""

# Step 4: Build C++ Extensions
Write-Host "[4/5] Building C++ extensions..." -ForegroundColor Yellow
cmake --build build
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ C++ extensions built successfully" -ForegroundColor Green
Write-Host ""

# Step 5: Set Environment Variables
Write-Host "[5/5] Setting environment variables..." -ForegroundColor Yellow
$jmodelicaHome = (Get-Location).Path
[Environment]::SetEnvironmentVariable("JMODELICA_HOME", $jmodelicaHome, [System.EnvironmentVariableTarget]::User)
$env:JMODELICA_HOME = $jmodelicaHome
Write-Host "✓ JMODELICA_HOME set to: $jmodelicaHome" -ForegroundColor Green
Write-Host ""

# Test Installation
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Testing Python imports..." -ForegroundColor Yellow
$pythonExe = "C:\Users\FoadS\AppData\Local\miniconda3\python.exe"

& $pythonExe -c "import pymodelica; print('✓ pymodelica imported successfully')"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ pymodelica OK" -ForegroundColor Green
} else {
    Write-Host "⚠ pymodelica import failed (may need additional configuration)" -ForegroundColor Yellow
}

& $pythonExe -c "import pyjmi; print('✓ pyjmi imported successfully')"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ pyjmi OK" -ForegroundColor Green
} else {
    Write-Host "⚠ pyjmi import failed (may need additional configuration)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Test an example:" -ForegroundColor White
Write-Host "   cd examples\000_simple_rc_circuit" -ForegroundColor Gray
Write-Host "   python simulate_rc.py" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Create your own Modelica models" -ForegroundColor White
Write-Host ""
Write-Host "For help, see: examples\README.md" -ForegroundColor White
