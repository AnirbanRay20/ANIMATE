$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " ANIMATE - Windows Environment Setup" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# Check Python 3.10
# ------------------------------------------------------------
Write-Host "[1/7] Checking Python 3.10..." -ForegroundColor Yellow

$python310 = $null

try {
    $python310 = (py -3.10 --version 2>&1)
} catch {
    $python310 = $null
}

if (-not $python310 -or $python310 -notmatch "Python 3\.10") {
    Write-Host ""
    Write-Host "Python 3.10 was not found through the Python launcher." -ForegroundColor Red
    Write-Host "Install Python 3.10 x64, then run this script again." -ForegroundColor Red
    Write-Host ""
    Write-Host "Check installed Python versions with:" -ForegroundColor Yellow
    Write-Host "    py --list"
    exit 1
}

Write-Host "Found: $python310" -ForegroundColor Green

# ------------------------------------------------------------
# Check venv
# ------------------------------------------------------------
Write-Host "[2/7] Creating virtual environment..." -ForegroundColor Yellow

if (-not (Test-Path ".\venv310\Scripts\python.exe")) {
    py -3.10 -m venv venv310
    Write-Host "Created venv310." -ForegroundColor Green
} else {
    Write-Host "venv310 already exists. Reusing it." -ForegroundColor Green
}

# ------------------------------------------------------------
# Activate
# ------------------------------------------------------------
Write-Host "[3/7] Activating virtual environment..." -ForegroundColor Yellow

& ".\venv310\Scripts\Activate.ps1"

$pythonVersion = & ".\venv310\Scripts\python.exe" --version
Write-Host "Environment Python: $pythonVersion" -ForegroundColor Green

# ------------------------------------------------------------
# Upgrade packaging tools
# ------------------------------------------------------------
Write-Host "[4/7] Updating pip/setuptools/wheel..." -ForegroundColor Yellow

& ".\venv310\Scripts\python.exe" -m pip install --upgrade pip setuptools wheel

# ------------------------------------------------------------
# Install requirements
# ------------------------------------------------------------
Write-Host "[5/7] Installing ANIMATE dependencies..." -ForegroundColor Yellow

& ".\venv310\Scripts\python.exe" -m pip install --no-cache-dir -r requirements.txt

# ------------------------------------------------------------
# Verification
# ------------------------------------------------------------
Write-Host "[6/7] Verifying installation..." -ForegroundColor Yellow

& ".\venv310\Scripts\python.exe" -c "import torch; print('PyTorch:', torch.__version__); print('CUDA:', torch.version.cuda); print('CUDA available:', torch.cuda.is_available())"

& ".\venv310\Scripts\python.exe" -c "import numpy; print('NumPy:', numpy.__version__)"

& ".\venv310\Scripts\python.exe" -c "import torch_geometric; print('PyG:', torch_geometric.__version__)"

& ".\venv310\Scripts\python.exe" -c "import torch_scatter; import torch_sparse; print('torch_scatter:', torch_scatter.__version__); print('torch_sparse:', torch_sparse.__version__)"

& ".\venv310\Scripts\python.exe" -c "import dgl; print('DGL:', dgl.__version__)"

& ".\venv310\Scripts\python.exe" -c "import Cython; print('Cython:', Cython.__version__)"

# ------------------------------------------------------------
# Optional algos.pyx check
# ------------------------------------------------------------
Write-Host "[7/7] Checking ANIMATE Cython module..." -ForegroundColor Yellow

& ".\venv310\Scripts\python.exe" -c "import algos; print('algos.pyx: OK')" 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "algos.pyx: OK" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "algos.pyx could not be imported yet." -ForegroundColor Yellow
    Write-Host "If this is the first setup, make sure Microsoft C++ Build Tools" -ForegroundColor Yellow
    Write-Host "with Desktop development with C++ and a Windows SDK are installed." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " ANIMATE setup completed" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

Write-Host "To activate the environment in a new PowerShell window:" -ForegroundColor Cyan
Write-Host "    .\venv310\Scripts\Activate.ps1" -ForegroundColor White
Write-Host ""

Write-Host "Run the Books dataset:" -ForegroundColor Cyan
Write-Host "    python train.py --dataset_name Books" -ForegroundColor White
Write-Host ""

Write-Host "Other datasets:" -ForegroundColor Cyan
Write-Host "    python train.py --dataset_name Disney" -ForegroundColor White
Write-Host "    python train.py --dataset_name Reddit" -ForegroundColor White
Write-Host "    python train.py --dataset_name Yelp" -ForegroundColor White
Write-Host ""
