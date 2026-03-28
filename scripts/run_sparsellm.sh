#!/bin/bash
# ============================================================
# SparseLLM Pruning + Perplexity Evaluation
# Models: LLaMA-3.2-3B, LLaMA-3.1-8B (matching DART paper)
# Sparsity: 50%, 70% (matching DART Table 1)
# ============================================================

set -e

# Activate venv
source "$HOME/sparsellm/bin/activate"

# --- Configuration ---
SPARSELLM_DIR="$(cd "$(dirname "$0")/../SparseLLM" && pwd)"
RESULTS_DIR="$(cd "$(dirname "$0")/.." && pwd)/results"
mkdir -p "$RESULTS_DIR"

# Models matching DART's main evaluation
MODELS=(
    "meta-llama/Llama-3.2-3B"
    "meta-llama/Llama-3.1-8B"
)

# Sparsity levels matching DART Table 1
SPARSITIES=(0.7)

# Calibration samples (SparseLLM paper uses 32-64)
NSAMPLES=16

# --- Run Experiments ---
for MODEL in "${MODELS[@]}"; do
    MODEL_SHORT=$(echo "$MODEL" | sed 's/.*\///')

    for SPARSITY in "${SPARSITIES[@]}"; do
        SPARSITY_PCT=$(echo "$SPARSITY * 100" | bc | cut -d. -f1)

        echo "========================================"
        echo "Model: $MODEL_SHORT | Sparsity: ${SPARSITY_PCT}%"
        echo "========================================"

        SAVE_DIR="$RESULTS_DIR/${MODEL_SHORT}_sp${SPARSITY_PCT}"
        LOG_FILE="$RESULTS_DIR/${MODEL_SHORT}_sp${SPARSITY_PCT}_ppl.log"

        cd "$SPARSELLM_DIR"
        python llama_main.py \
            --model "$MODEL" \
            --dataset c4 \
            --sparsity "$SPARSITY" \
            --nsamples "$NSAMPLES" \
            --save "$SAVE_DIR" \
            2>&1 | tee "$LOG_FILE"

        echo "Perplexity results saved to: $LOG_FILE"
        echo "Pruned model saved to: $SAVE_DIR"
        echo ""
    done
done

echo "============================================"
echo "All perplexity experiments complete!"
echo "Results directory: $RESULTS_DIR"
echo ""
echo "Next: bash scripts/run_zeroshot_eval.sh"
echo "============================================"
