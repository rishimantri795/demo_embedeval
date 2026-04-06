# EmbedBench Demo

A benchmark for AI agents fixing bugs in embedded systems firmware (Zephyr RTOS).

## Prerequisites

- Docker Desktop (running)
- Python 3.10+
- An Anthropic or OpenAI API key

## Setup

```bash
git clone <this-repo>
cd <this-repo>
bash setup.sh
```

Then set your API key:

```bash
export ANTHROPIC_API_KEY=sk-ant-...
# or
export OPENAI_API_KEY=sk-...
```

---

## What's in this repo

Two Zephyr RTOS bug instances, each pre-loaded in a Docker image:

| Instance | Bug |
|---|---|
| `zephyr__zephyr-65697` | `pthread_key_delete()` always frees bit offset 0 instead of the actual key's offset, causing a resource leak |
| `zephyr__zephyr-43405` | `log_init()` enables logging backends without checking if they're ready, losing early boot messages |

---

## Running the agent

The agent is given the bug description and has to explore the codebase, identify the fix, and submit a patch — all autonomously inside the Docker container.

```bash
# Instance 1
python harness/run_instance.py --instance zephyr__zephyr-65697 --verbose

# Instance 2
python harness/run_instance.py --instance zephyr__zephyr-43405 --verbose
```

The agent's patch is saved to `outputs/<instance_id>.patch` when it finishes.

**Options:**

```
--model anthropic/claude-sonnet-4-6   Model to use (LiteLLM format)
--step-limit 50                        Max agent steps
--cost-limit 3.0                       Max spend in USD
--verbose / -v                         Stream agent thoughts + commands live
```

---

## Validating an instance

This runs the canonical two-step check: verify tests **fail** on the broken code, then apply the fix and verify they **pass**.

```bash
# Validate with the official fix (fetched from GitHub)
bash scripts/validate_instance.sh zephyr__zephyr-65697
bash scripts/validate_instance.sh zephyr__zephyr-43405

# Validate with the agent's generated patch instead
bash scripts/validate_instance.sh zephyr__zephyr-65697 outputs/zephyr__zephyr-65697.patch
bash scripts/validate_instance.sh zephyr__zephyr-43405 outputs/zephyr__zephyr-43405.patch
```

Expected output:

```
=== Step 1: Verifying tests FAIL on broken code ===
...
 FAIL - test_key_resource_leak
 FAIL - test_correct_key_is_deleted
==> run_tests: PROJECT EXECUTION FAILED

=== Step 2: Applying fix and verifying tests PASS ===
...
 PASS - test_key_resource_leak
 PASS - test_correct_key_is_deleted
==> run_tests: PROJECT EXECUTION SUCCESSFUL

=== Validation complete ===
```
