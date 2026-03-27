#!/bin/bash
# ============================================================
# Zero-Shot Evaluation of SparseLLM-pruned Models
# Uses lm-eval-harness to evaluate on the same benchmarks
# as DART's Appendix B tables.
#
# Prerequisites:
#   pip install lm-eval
#
# Run this AFTER run_sparsellm.sh has completed.
# ============================================================

set -e

RESULTS_DIR="$(cd "$(dirname "$0")/.." && pwd)/results"

# Zero-shot tasks matching DART's evaluation (Table 4 & 5 in Appendix B)
TASKS="boolq,rte,hellaswag,winogrande,arc_easy,arc_challenge,openbookqa"

# Models and sparsity levels (must match run_sparsellm.sh)
CONFIGS=(
    "Llama-2-7b-hf:70"
    "Llama-2-7b-hf:80"
    "Llama-2-13b-hf:70"
    "Llama-2-13b-hf:80"
)

for CONFIG in "${CONFIGS[@]}"; do
    MODEL_SHORT="${CONFIG%%:*}"
    SPARSITY="${CONFIG##*:}"
    
    MODEL_DIR="$RESULTS_DIR/${MODEL_SHORT}_sp${SPARSITY}"
    EVAL_LOG="$RESULTS_DIR/${MODEL_SHORT}_sp${SPARSITY}_zeroshot.json"
    
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
        --tasks "$TASKS" \
        --batch_size auto \
        --num_fewshot 0 \
        --output_path "$EVAL_LOG" \
        2>&1 | tee "$RESULTS_DIR/${MODEL_SHORT}_sp${SPARSITY}_zeroshot.log"
    
    echo "Results saved to: $EVAL_LOG"
    echo ""
done

echo "============================================"
echo "All zero-shot evaluations complete!"
echo "Results directory: $RESULTS_DIR"
echo "============================================"
