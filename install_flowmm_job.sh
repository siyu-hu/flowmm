#!/bin/bash
#SBATCH --job-name=install_flowmm
#SBATCH -A naiss2024-5-630
#SBATCH -p alvis
#SBATCH -N 1 --gpus-per-node=A40:1
#SBATCH -t 2:00:00
#SBATCH --output=/mimer/NOBACKUP/groups/naiss2023-6-290/husi/logs/install_flowmm_%j.out
#SBATCH --error=/mimer/NOBACKUP/groups/naiss2023-6-290/husi/logs/install_flowmm_%j.err
#SBATCH --mail-user=husi@chalmers.se
#SBATCH --mail-type=ALL

echo "Starting FlowMM environment installation"
echo "Job ID: $SLURM_JOB_ID"
echo "Started at: $(date)"

cd /mimer/NOBACKUP/groups/naiss2023-6-290/husi/flowmm

# Run create_env_file.sh first (may fix virtualenv issues)
echo "Creating .env file..."
bash create_env_file.sh
source .env

# Set micromamba/conda paths to use project storage (avoid /cephyr quota issues)
export MAMBA_ROOT_PREFIX="/mimer/NOBACKUP/groups/naiss2023-6-290/husi/.mamba"
export MAMBA_PKGS_DIRS="/mimer/NOBACKUP/groups/naiss2023-6-290/husi/.mamba/pkgs"
export CONDA_ENVS_PATH="/mimer/NOBACKUP/groups/naiss2023-6-290/husi/.mamba/envs"
export CONDA_PKGS_DIRS="/mimer/NOBACKUP/groups/naiss2023-6-290/husi/.mamba/pkgs"

echo "Using micromamba paths:"
echo "MAMBA_ROOT_PREFIX: $MAMBA_ROOT_PREFIX"
echo "MAMBA_PKGS_DIRS: $MAMBA_PKGS_DIRS"

# Check if environment already exists
if ./bin/micromamba env list | grep -q "flowmm"; then
    echo "FlowMM environment already exists! Skipping conda installation."
    CONDA_SUCCESS=true
else
    echo "Creating conda-only environment..."
    # Create a temporary environment.yml with only conda packages (remove pip section)
    sed '/^  - pip:/,$d' environment.yml > environment_conda_only.yml

    ./bin/micromamba env create -f environment_conda_only.yml -y
    CONDA_SUCCESS=$?
fi

# Check result and run pip install if conda packages succeeded
if [ "$CONDA_SUCCESS" = true ] || [ $? -eq 0 ]; then
    echo "Conda packages installed successfully! Now installing pip packages..."
    
    # Try different pip installation methods to fix virtualenv issue
    echo "Installing pip packages..."
    
    # Method 1: Set PIP_REQUIRE_VIRTUALENV=false to bypass virtualenv requirement
    export PIP_REQUIRE_VIRTUALENV=false
    
    # Install pip packages individually
    echo "Installing core pip packages..."
    if ! ./bin/micromamba run -n flowmm pip install submitit==1.5.1 pre-commit==3.6.1 black==22.6.0 ipykernel==6.29.2; then
        echo "Standard pip failed, trying alternative method..."
        # Method 2: Use python -m pip with --user flag disabled
        ./bin/micromamba run -n flowmm python -m pip install --no-user submitit==1.5.1 pre-commit==3.6.1 black==22.6.0 ipykernel==6.29.2
    fi
    ./bin/micromamba run -n flowmm pip install torchdiffeq==0.2.3 scikit-learn==1.4.0 pytorch-lightning==1.8.5.post0
    ./bin/micromamba run -n flowmm pip install hydra-core==1.2.0 hydra-submitit-launcher==1.2.0 hydra_colorlog==1.2.0
    ./bin/micromamba run -n flowmm pip install click==8.1.7 wandb geoopt==0.5.0 biopython==1.83
    ./bin/micromamba run -n flowmm pip install pyevtk==1.6.0 ipympl==0.9.3 smact==2.2.1 pytest==8.0.0
    ./bin/micromamba run -n flowmm pip install python-dotenv==1.0.1 p-tqdm==1.3.3 pyshtools==4.10.4
    ./bin/micromamba run -n flowmm pip install pyxtal==0.6.1 chemparse==0.1.3 einops==0.7.0 ratelimit==2.2.1
    ./bin/micromamba run -n flowmm pip install matbench-discovery==1.0.0 pymatviz==0.8.1 chgnet==0.3.1
    ./bin/micromamba run -n flowmm pip install toolz==0.12.1 POT==0.9.3 e3nn==0.5.1 mp-api==0.39.5 matminer
    
    echo "Installing PyTorch Geometric with custom index..."
    ./bin/micromamba run -n flowmm pip install --find-links https://data.pyg.org/whl/torch-2.1.0+cu118.html pyg_lib
    
    echo "Installing local packages in development mode..."
    ./bin/micromamba run -n flowmm pip install -e remote/cdvae
    ./bin/micromamba run -n flowmm pip install -e remote/DiffCSP-official  
    ./bin/micromamba run -n flowmm pip install -e remote/riemannian-fm
    ./bin/micromamba run -n flowmm pip install -e .
    
    if [ $? -eq 0 ]; then
        echo "Installation completed successfully!"
        ./bin/micromamba env list
        echo "Testing basic imports..."
        ./bin/micromamba run -n flowmm python -c "import torch; print('PyTorch version:', torch.__version__)"
        ./bin/micromamba run -n flowmm python -c "import e3nn; print('e3nn version:', e3nn.__version__)"
    else
        echo "Pip installation failed!"
        exit 1
    fi
else
    echo "Conda installation failed!"
    exit 1
fi

echo "Finished at: $(date)"
