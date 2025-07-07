#!/bin/bash
#SBATCH --job-name=test_flowmm_quick
#SBATCH -A naiss2024-5-630
#SBATCH -p alvis
#SBATCH -N 1 --gpus-per-node=A40:1
#SBATCH -t 0:30:00  # 30分钟足够快速测试
#SBATCH --output=/mimer/NOBACKUP/groups/naiss2023-6-290/husi/logs/test_flowmm_quick_%j.out
#SBATCH --error=/mimer/NOBACKUP/groups/naiss2023-6-290/husi/logs/test_flowmm_quick_%j.err
#SBATCH --mail-user=husi@chalmers.se
#SBATCH --mail-type=ALL

echo "Starting FlowMM quick test"
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

echo "Environment activated, testing basic imports..."
python -c "import torch; print('✅ PyTorch:', torch.__version__, '- CUDA available:', torch.cuda.is_available())"
python -c "import e3nn; print('✅ e3nn:', e3nn.__version__)"
python -c "import flowmm; print('✅ FlowMM imported successfully')"

echo "Starting quick FlowMM test (limited samples and epochs)..."
python scripts_model/run.py \
    data=mp20_llama \
    model=null_params \
    base_distribution_from_data=True \
    data.datamodule.datasets.train.num_samples=100 \
    data.datamodule.datasets.val.num_samples=50 \
    trainer.max_epochs=1 \
    trainer.limit_train_batches=10 \
    trainer.limit_val_batches=5 \
    trainer.log_every_n_steps=5

echo "Quick test completed at: $(date)"
