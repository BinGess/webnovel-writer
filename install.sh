#!/usr/bin/env bash
set -euo pipefail

REPO="${WEBNOVEL_REPO:-lingfengQAQ/webnovel-writer}"
REF="${WEBNOVEL_REF:-main}"
MARKETPLACE="${WEBNOVEL_MARKETPLACE:-webnovel-writer}"
PLUGIN="${WEBNOVEL_PLUGIN:-webnovel-writer}"
INSTALL_PYTHON_DEPS="${INSTALL_PYTHON_DEPS:-1}"

if ! command -v codex >/dev/null 2>&1; then
  echo "ERROR: codex CLI not found. Install and sign in to Codex first." >&2
  echo "See: https://developers.openai.com/codex" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 not found. Webnovel Writer requires Python 3.10+." >&2
  exit 1
fi

echo "==> Adding Codex marketplace ${MARKETPLACE} from ${REPO}@${REF}"
if ! codex plugin marketplace add "${REPO}@${REF}" \
  --sparse .agents/plugins \
  --sparse webnovel-writer; then
  echo "==> Marketplace may already exist; upgrading ${MARKETPLACE}"
  codex plugin marketplace upgrade "${MARKETPLACE}" || true
fi

echo "==> Installing Codex plugin ${PLUGIN}@${MARKETPLACE}"
codex plugin add "${PLUGIN}@${MARKETPLACE}"

if [ "${INSTALL_PYTHON_DEPS}" != "0" ]; then
  REQUIREMENTS_URL="https://raw.githubusercontent.com/${REPO}/${REF}/requirements.txt"
  echo "==> Installing Python dependencies from ${REQUIREMENTS_URL}"
  python3 -m pip install --user -r "${REQUIREMENTS_URL}"
else
  echo "==> Skipping Python dependency install because INSTALL_PYTHON_DEPS=0"
fi

cat <<'EOF'

Webnovel Writer is installed.

Next steps:
1. Restart Codex if the plugin was not visible before.
2. Start a new Codex thread.
3. Type: $webnovel-init

EOF
