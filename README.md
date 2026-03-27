# SparseLLM Baseline Comparison for DART

Running SparseLLM as a baseline comparison for the DART paper revision.

## Setup
```bash
git clone https://github.com/BaiTheBest/SparseLLM.git
pip install torch transformers datasets numpy pandas huggingface_hub wandb
```

## Models
- LLaMA-2-7B (`meta-llama/Llama-2-7b-hf`)
- LLaMA-2-13B (`meta-llama/Llama-2-13b-hf`)

## Sparsity Levels
- 70%, 80% unstructured
