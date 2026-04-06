#!/usr/bin/env bash
# One-time setup: pull Docker images and install Python dependencies.
# Run this before using run_instance.py or validate_instance.sh.

set -euo pipefail

# ─── Prerequisites check ────────────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
    echo "ERROR: Docker not found. Install Docker Desktop: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

if ! docker info &>/dev/null; then
    echo "ERROR: Docker daemon is not running. Start Docker Desktop and try again."
    exit 1
fi

if ! command -v python3 &>/dev/null; then
    echo "ERROR: python3 not found."
    exit 1
fi

# ─── Pull instance images ────────────────────────────────────────────────────
echo "Pulling instance images (this may take a few minutes on first run)..."
docker pull rishimantri/embedbench-zephyr-65697:latest
docker pull rishimantri/embedbench-zephyr-43405:latest
echo ""

# ─── Python dependencies ─────────────────────────────────────────────────────
echo "Installing Python dependencies..."
pip install -r "$(dirname "$0")/requirements.txt"
echo ""

# ─── Done ────────────────────────────────────────────────────────────────────
echo "Setup complete."
echo ""
echo "Next steps:"
echo "  1. Set your API key:"
echo "       export ANTHROPIC_API_KEY=sk-ant-..."
echo "       # or: export OPENAI_API_KEY=sk-..."
echo ""
echo "  2. Run the agent on an instance:"
echo "       python harness/run_instance.py --instance zephyr__zephyr-65697 --verbose"
echo "       python harness/run_instance.py --instance zephyr__zephyr-43405 --verbose"
echo ""
echo "  3. Validate an instance (see tests fail then pass):"
echo "       bash scripts/validate_instance.sh zephyr__zephyr-65697"
echo "       bash scripts/validate_instance.sh zephyr__zephyr-43405"
echo ""
echo "  4. Validate the agent's patch:"
echo "       bash scripts/validate_instance.sh zephyr__zephyr-65697 outputs/zephyr__zephyr-65697.patch"
