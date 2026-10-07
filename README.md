# ANIMATE — Fork Setup Guide

This repository is a fork/setup of:

> **ANIMATE: Unsupervised Attributed Graph Anomaly Detection with Masked Graph Transformers**

The purpose of this README is to make the project reproducible on **Windows**, using the dependency versions tested for this fork.

---

## 1. Tested Environment

The following baseline was successfully used to train and evaluate the **Books** dataset:

| Component | Version |
|---|---|
| OS | Windows 10/11 |
| Python | **3.10.11 (64-bit)** |
| PyTorch | **2.1.2+cpu** |
| CUDA | Not required for the tested CPU setup |
| NumPy | **1.26.4** |
| SciPy | **1.15.3** |
| scikit-learn | **1.7.2** |
| PyTorch Geometric | **2.4.0** |
| DGL | **2.2.1** |
| Cython | **0.29.36** |
| torch-scatter | **2.1.2+pt21cpu** |
| torch-sparse | **0.6.18+pt21cpu** |

### Important

Use **Python 3.10 64-bit** for this fork.

The original code contains a Cython file (`algos.pyx`) that is compiled at runtime through `pyximport`. Python 3.14 caused compatibility/build problems during setup, so the tested environment is intentionally pinned to Python 3.10.

---

# 2. Repository Structure

The important files are approximately:

```text
ANIMATE/
│
├── data/
│   ├── Books
│   ├── Disney
│   ├── Reddit
│   └── Yelp
│
├── algos.pyx
├── load_data.py
├── load_pygData.py
├── train.py
├── utils.py
├── requirements.txt
├── setup_windows.ps1
└── README.md
```

Do not commit the virtual environment folder.

---

# 3. Prerequisites

Install the following before running the project:

1. **Python 3.10 64-bit**
2. **Git**
3. **Microsoft C++ Build Tools**

The C++ compiler is required because `algos.pyx` is compiled into a native Python extension.

### Microsoft C++ Build Tools

Install Visual Studio Build Tools and select:

- Desktop development with C++
- MSVC build tools
- Windows SDK

After installation, restart PowerShell.

---

# 4. Clone the Repository

```powershell
git clone <YOUR-FORK-URL>
cd ANIMATE
```

If you are already inside the fork directory, simply continue with the setup.

---

# 5. Recommended One-Command Windows Setup

PowerShell can create the complete environment automatically.

Run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup_windows.ps1
```

The script:

1. Checks that Python 3.10 is available.
2. Creates `venv310`.
3. Activates the virtual environment.
4. Upgrades pip/setuptools/wheel.
5. Installs the pinned dependencies.
6. Checks PyTorch.
7. Checks PyTorch Geometric.
8. Checks `torch_sparse` and `torch_scatter`.
9. Checks DGL.
10. Checks Cython.
11. Prints the final environment information.

---

# 6. Manual Setup

If you prefer to install everything manually:

## Step 1 — Create Python 3.10 environment

```powershell
py -3.10 -m venv venv310
```

Activate:

```powershell
.\venv310\Scripts\Activate.ps1
```

Verify:

```powershell
python --version
```

Expected:

```text
Python 3.10.11
```

Also verify:

```powershell
python -c "import sys; print(sys.executable)"
```

It should point to:

```text
...\ANIMATE\venv310\Scripts\python.exe
```

---

## Step 2 — Upgrade packaging tools

```powershell
python -m pip install --upgrade pip setuptools wheel
```

---

## Step 3 — Install all project dependencies

```powershell
python -m pip install -r requirements.txt
```

The requirements file contains the pinned PyTorch/PyG/DGL/Cython stack required by this fork.

---

# 7. Verify the Environment

Run:

```powershell
python -c "import torch; print('PyTorch:', torch.__version__); print('CUDA:', torch.version.cuda); print('CUDA available:', torch.cuda.is_available())"
```

Expected CPU baseline:

```text
PyTorch: 2.1.2+cpu
CUDA: None
CUDA available: False
```

Check NumPy:

```powershell
python -c "import numpy; print('NumPy:', numpy.__version__)"
```

Check PyTorch Geometric:

```powershell
python -c "import torch_geometric; print('PyG:', torch_geometric.__version__)"
```

Check PyG native extensions:

```powershell
python -c "import torch_scatter; import torch_sparse; print('torch_scatter:', torch_scatter.__version__); print('torch_sparse:', torch_sparse.__version__)"
```

Check DGL:

```powershell
python -c "import dgl; print('DGL:', dgl.__version__)"
```

Check DGL graph loading:

```powershell
python -c "from dgl.data.utils import load_graphs; print('DGL load_graphs: OK')"
```

Check Cython:

```powershell
python -c "import Cython; print('Cython:', Cython.__version__)"
```

---

# 8. Cython `algos.pyx`

ANIMATE contains:

```text
algos.pyx
```

The project uses `pyximport` to compile this file when `utils.py` imports `algos`.

The file implements graph-processing functionality including:

- Floyd-Warshall shortest-path calculation
- shortest-path reconstruction
- edge-feature extraction along paths

Because it is compiled code, the Windows C++ build tools are required.

## Test the Cython module

After installing the dependencies, run:

```powershell
python -c "import algos; import numpy as np; A=np.array([[0,1,0],[1,0,1],[0,1,0]], dtype=np.int64); M,P=algos.floyd_warshall(A); print('Distance:'); print(M); print('Path:'); print(P)"
```

If this completes without a Cython/compiler error, the `algos.pyx` build is working.

---

# 9. Dataset

The repository expects datasets in:

```text
data/
```

The original ANIMATE project provides the supported datasets:

- Books
- Disney
- Reddit
- Yelp

If your fork already contains the datasets, no additional download is required.

The original project also notes that `Yelp.pt` can be obtained from the PyGOD repository.

---

# 10. Run ANIMATE

Make sure the environment is activated:

```powershell
.\venv310\Scripts\Activate.ps1
```

Then run:

```powershell
python train.py --dataset_name Books
```

---

# 11. Other Datasets

### Disney

```powershell
python train.py --dataset_name Disney
```

### Reddit

```powershell
python train.py --dataset_name Reddit
```

### Yelp

```powershell
python train.py --dataset_name Yelp
```

---

# 12. Expected Training Flow

For a successful run, the program should show a training progress bar similar to:

```text
Books
Training: 100%|████████████████████████| 300/300
```

Then the model is loaded for evaluation:

```text
Loading 0th epoch model
Testing: 100%|██████████████████████████| ...
```

Finally, evaluation metrics are printed, for example:

```text
Books  AUROC: ..., AUPRC: ..., AP: ...
```

The exact metric values can vary depending on the environment, dataset, and implementation state.

---

# 13. CPU Execution

The tested environment uses CPU PyTorch:

```text
PyTorch: 2.1.2+cpu
CUDA: None
CUDA available: False
```

The original training code contains CUDA-specific operations. If your local copy has not been adapted for CPU execution, an error such as:

```text
AssertionError: Torch not compiled with CUDA enabled
```

may occur.

For the CPU-tested fork, CUDA-specific tensor creation in the training/evaluation path must use the selected device rather than forcing `.cuda()`.

For example, code such as:

```python
torch.ones(...).cuda()
```

should be changed to use the project's device variable, such as:

```python
torch.ones(..., device=device)
```

Only make this change if the fork is intended to support CPU execution.

---

# 14. Important Warnings

You may see warnings such as:

```text
UserWarning: size_average and reduce args will be deprecated
```

or:

```text
UserWarning: torch.sparse.SparseTensor(...) is deprecated
```

These are deprecation warnings and are not necessarily execution failures.

The important distinction is:

```text
Warning
```

versus:

```text
Traceback
```

A traceback indicates that execution stopped because of an error.

---

# 15. Git — Do NOT Commit the Virtual Environment

Do **not** commit:

```text
venv/
venv310/
```

These folders contain compiled libraries and thousands of files.

Instead, commit:

```text
requirements.txt
setup_windows.ps1
README.md
```

and the project source/data files that belong to the repository.

Recommended `.gitignore` entries:

```gitignore
# Python
__pycache__/
*.py[cod]
*.pyd

# Virtual environments
venv/
venv310/
.env/
.venv/

# Cython/build output
.pyxbld/
build/
dist/
*.so
*.dll
*.lib
*.exp

# IDE
.vscode/
.idea/

# Jupyter
.ipynb_checkpoints/

# OS
.DS_Store
Thumbs.db
```

---

# 16. Recommended Team Workflow

For a team member who has cloned the fork:

```powershell
git clone <YOUR-FORK-URL>
cd ANIMATE
```

Then:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup_windows.ps1
```

Activate the environment if the setup script has finished:

```powershell
.\venv310\Scripts\Activate.ps1
```

Run:

```powershell
python train.py --dataset_name Books
```

This allows every team member to use the same pinned dependency versions instead of installing packages individually.

---

# 17. Troubleshooting

## `ModuleNotFoundError: No module named 'torch_geometric'`

Run:

```powershell
python -m pip install -r requirements.txt
```

Then:

```powershell
python -c "import torch_geometric; print(torch_geometric.__version__)"
```

---

## `ModuleNotFoundError: No module named 'torch_sparse'`

Install the PyG native extensions using the versions specified in `requirements.txt`.

Then test:

```powershell
python -c "from torch_sparse import SparseTensor; print('SparseTensor: OK')"
```

---

## `ModuleNotFoundError: No module named 'dgl'`

Run:

```powershell
python -m pip install -r requirements.txt
```

Then:

```powershell
python -c "import dgl; print('DGL:', dgl.__version__)"
```

---

## `ModuleNotFoundError: No module named 'yaml'`

The package name is **PyYAML**, not `yaml`.

Install:

```powershell
python -m pip install PyYAML
```

or reinstall all requirements:

```powershell
python -m pip install -r requirements.txt
```

---

## `ImportError: Building module algos failed`

First verify Cython:

```powershell
python -c "import Cython; print(Cython.__version__)"
```

The tested version is:

```text
0.29.36
```

Then verify that Microsoft C++ Build Tools are installed.

Finally test:

```powershell
python -c "import algos; print('algos: OK')"
```

---

## `Microsoft Visual C++ 14.0 or greater is required`

Install Microsoft C++ Build Tools with:

- Desktop development with C++
- MSVC
- Windows SDK

Then restart PowerShell and retry.

---

## `Torch not compiled with CUDA enabled`

This means the installed PyTorch build is CPU-only while the code is attempting to use CUDA.

Check:

```powershell
python -c "import torch; print(torch.__version__); print(torch.cuda.is_available())"
```

For the tested CPU setup:

```text
2.1.2+cpu
False
```

The training code must therefore use CPU-safe device handling.

---

# 18. Clean Reinstallation

If the environment becomes corrupted, remove it and recreate it.

Deactivate:

```powershell
deactivate
```

Delete:

```powershell
Remove-Item -Recurse -Force .\venv310
```

Create again:

```powershell
py -3.10 -m venv venv310
```

Activate:

```powershell
.\venv310\Scripts\Activate.ps1
```

Install:

```powershell
python -m pip install --upgrade pip setuptools wheel
python -m pip install -r requirements.txt
```

Then verify the environment before running training.

---

# 19. Reproducibility

For this fork, the dependency versions are intentionally pinned.

Do not casually upgrade:

- PyTorch
- PyTorch Geometric
- torch-scatter
- torch-sparse
- DGL
- Cython

without retesting the complete training pipeline.

The project contains both PyTorch Geometric and DGL components, as well as a Cython extension, so changing one major dependency can affect compatibility with the others.

---

# 20. Original Project Usage

The original usage pattern is:

```powershell
python train.py --dataset_name Books
python train.py --dataset_name Disney
python train.py --dataset_name Reddit
python train.py --dataset_name Yelp
```

This fork adds the reproducible Windows setup, dependency pinning, Cython/compiler setup notes, CPU environment notes, verification commands, and troubleshooting instructions required to reproduce the tested setup.

---

## Quick Start

For an already configured Windows machine:

```powershell
py -3.10 -m venv venv310
.\venv310\Scripts\Activate.ps1
python -m pip install --upgrade pip setuptools wheel
python -m pip install -r requirements.txt
python train.py --dataset_name Books
```

For a complete setup:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup_windows.ps1
```

Then:

```powershell
.\venv310\Scripts\Activate.ps1
python train.py --dataset_name Books
```

---

## Project

**ANIMATE: Unsupervised Attributed Graph Anomaly Detection with Masked Graph Transformers**

This repository is intended for research, experimentation, reproducibility, and further development of graph anomaly detection using attributed graphs and masked graph transformer architectures.

---

## 21. Contributors

| Name | GitHub Profile | Email |
| --- | --- | --- |
| ANIRBAN RAY | https://github.com/AnirbanRay20 | anirbanmark1429@gmail.com |
| Contributor 2 |  |  |
| Contributor 3 |  |  |
| Contributor 4 |  |  |
