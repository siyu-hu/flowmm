#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
MAMBA_DIR="$(dirname "${SCRIPT_DIR}")/.mamba"

cat > .env <<EOL
export PROJECT_ROOT="${SCRIPT_DIR}"
export HYDRA_JOBS="${SCRIPT_DIR}"
export WANDB_DIR="${SCRIPT_DIR}"

# Mamba/Conda configuration
export MAMBA_ROOT_PREFIX="${MAMBA_DIR}"
export MAMBA_EXE="${SCRIPT_DIR}/bin/micromamba"
export CONDARC="${MAMBA_DIR}/.condarc"

# Cache directories
export CONDA_PKGS_DIRS="${MAMBA_DIR}/pkgs"
export PIP_CACHE_DIR="${MAMBA_DIR}/pip_cache"

# Python configuration
export PYTHONPATH="\${PROJECT_ROOT}/src:\${PYTHONPATH}"

# Add micromamba to PATH
export PATH="${SCRIPT_DIR}/bin:\${PATH}"
EOL

cp .env "${SCRIPT_DIR}/remote/DiffCSP-official"
cp .env "${SCRIPT_DIR}/remote/cdvae"
