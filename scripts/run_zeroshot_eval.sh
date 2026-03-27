#!/bin/bash
# ============================================================
# Zero-Shot + Multi-Shot Evaluation (matching DART Table 1)
#
# Zero-shot: BoolQ, RTE, HellaSwag, WinoGrande, ARC-e, ARC-c, OBQA
# Multi-shot (5-shot): MMLU, GPQA, MedMCQA
#
# Prerequisites: pip install lm-eval
# Run AFTER run_sparsellm.sh
# ============================================================

set -e

# Activate venv
source "$HOME/sparsellm/bin/activate"

RESULTS_DIR="$(cd "$(dirname "$0")/.." && pwd)/results"

# Zero-shot tasks (matching DART Table 1 top section)
ZEROSHOT_TASKS="boolq,rte,hellaswag,winogrande,arc_easy,arc_challenge,openbookqa"

# Domain-specific 5-shot tasks (matching DART Table 1 bottom section)
FEWSHOT_TASKS="mmlu,gpqa,medmcqa"

# Configs: model:sparsity (must match run_sparsellm.sh)
CONFIGS=(
    "Llama-3.2-3B:50"
    "Llama-3.2-3B:70"
    "Llama-3.1-8B:50"
    "Llama-3.1-8B:70"
)

for CONFIG in "${CONFIGS[@]}"; do
    MODEL_SHORT="${CONFIG%%:*}"
    SPARSITY="${CONFIG##*:}"

    MODEL_DIR="$RESULTS_DIR/${MODEL_SHORT}_sp${SPARSITY}"

    if [ ! -d "$MODEL_DIR" ]; then
        echo "WARNING: $MODEL_DIR not found. Skipping. Run run_sparsellm.sh first."
        continue
    fi

    echo "========================================"
    echo "Zero-shot eval: $MODEL_SHORT @ ${SPARSITY}% sparsity"
    echo "========================================"

    lm_eval \
        --model hf \
        --model_args pretrained="$MODEL_DIR",dtype=float16 \
        --tasks "$ZEROSHOT_TASKS" \
        --batch_size auto \
        --num_fewshot 0 \
        --output_path "$RESULTS_DIR/${MODEL_SHORT}_sp${SPARSITY}_zeroshot.json" \
        2>&1 | tee "$RESULTS_DIR/${MODEL_SHORT}_sp${SPARSITY}_zeroshot.log"

    echo "========================================"
    echo "5-shot eval: $MODEL_SHORT @ ${SPARSITY}% sparsity"
    echo "========================================"

    lm_eval \
        --model hf \
        --model_args pretrained="$MODEL_DIR",dtype=float16 \
        --tasks "$FEWSHOT_TASKS" \
        --batch_size auto \
        --num_fewshot 5 \
        --output_path "$RESULTS_DIR/${MODEL_SHORT}_sp${SPARSITY}_fewshot.json" \
        2>&1 | tee "$RESULTS_DIR/${MODEL_SHORT}_sp${SPARSITY}_fewshot.log"

    echo ""
done

echo "============================================"
echo "All evaluations complete!"
echo "Results directory: $RESULTS_DIR"
echo "============================================"
