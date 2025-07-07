#!/bin/bash
#SBATCH --job-name=train_flowmm_full
#SBATCH -A naiss2024-5-630
#SBATCH -p alvis
#SBATCH -N 1 --gpus-per-node=A40:1
#SBATCH -t 24:00:00  # 24小时用于完整训练
#SBATCH --output=/mimer/NOBACKUP/groups/naiss2023-6-290/husi/logs/train_flowmm_full_%j.out
#SBATCH --error=/mimer/NOBACKUP/groups/naiss2023-6-290/husi/logs/train_flowmm_full_%j.err
#SBATCH --mail-user=husi@chalmers.se
#SBATCH --mail-type=ALL

echo "Starting FlowMM full training"
echo "Job ID: $SLURM_JOB_ID"
echo "Started at: $(date)"

cd /mimer/NOBACKUP/groups/naiss2023-6-290/husi/flowmm

# Set up environment
source .env
export MAMBA_ROOT_PREFIX="/mimer/NOBACKUP/groups/naiss2023-6-290/husi/.mamba"
export MAMBA_PKGS_DIRS="/mimer/NOBACKUP/groups/naiss2023-6-290/husi/.mamba/pkgs"
export CONDA_ENVS_PATH="/mimer/NOBACKUP/groups/naiss2023-6-290/husi/.mamba/envs"
export CONDA_PKGS_DIRS="/mimer/NOBACKUP/groups/naiss2023-6-290/husi/.mamba/pkgs"

# Initialize micromamba and activate environment
eval "$(./bin/micromamba shell hook --shell bash)"
micromamba activate flowmm

echo "Environment activated, starting full FlowMM training..."
echo "Dataset: mp20_llama (3M+ samples)"
echo "Expected duration: 12-24 hours"

python scripts_model/run.py \
    data=mp20_llama \
    model=null_params \
    base_distribution_from_data=True

echo "Full training completed at: $(date)"
