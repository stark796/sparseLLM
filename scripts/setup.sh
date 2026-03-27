#!/bin/bash
# ============================================================
# Setup script - run this on the GPU server after git clone
# ============================================================

set -e

VENV_DIR="$HOME/venv"

# Create venv if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment at $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
fi

echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

echo "Installing dependencies..."
pip install torch transformers datasets numpy pandas huggingface_hub wandb lm-eval

echo ""
echo "Setup complete!"
echo ""
echo "IMPORTANT: Before running experiments, always activate the venv first:"
echo "  source ~/venv/bin/activate"
echo ""
echo "Then run:"
echo "  bash scripts/run_sparsellm.sh"
echo ""
echo "Make sure you have access to LLaMA models:"
echo "  huggingface-cli login"
