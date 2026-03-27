#!/bin/bash
# ============================================================
# Setup script - run this on the GPU server after git clone
# ============================================================

set -e

echo "Installing dependencies..."
pip install torch transformers datasets numpy pandas huggingface_hub wandb
pip install lm-eval

echo ""
echo "Setup complete! Run experiments with:"
echo "  bash scripts/run_sparsellm.sh"
echo ""
echo "Make sure you have access to LLaMA models on HuggingFace:"
echo "  huggingface-cli login"
