# Deploy Fabric Resources Script
# To set up Python environment and deploy Fabric resources using the provided script.

# Exit Codes:
# 10 = usage/invalid args
# 20 = failed to download create_fabric_items.py
# 21 = failed to download fabric_api.py
# 22 = failed to download powerbi_api.py
# 30 = pip requirements install failed
# 31 = no Python interpreter found
# 40 = create_fabric_items.py failed (python3)
# 41 = create_fabric_items.py failed (python)


set -e

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <repoBaseUrl> <fabricWorkspaceId>"
  exit 1
fi

BASE_URL="$1"
WORKSPACE_ID="$2"

# Ensure trailing slash
if [[ "${BASE_URL: -1}" != "/" ]]; then
  BASE_URL="${BASE_URL}/"
fi

TMP_DIR=$(mktemp -d)
trap 'rc=$?; echo "Script exiting with code $rc"; rm -rf "$TMP_DIR"; exit $rc' EXIT

cd "$TMP_DIR"

echo "Working directory: $TMP_DIR"
echo "Downloading deployment artifacts from $BASE_URL"

if ! curl -fsSL "${BASE_URL}infra/deploy/fabric/create_fabric_items.py" -o create_fabric_items.py; then
  echo "Failed to download create_fabric_items.py"
  exit 20
fi
if ! curl -fsSL "${BASE_URL}infra/deploy/fabric/fabric_api.py" -o fabric_api.py; then
  echo "Failed to download fabric_api.py"
  exit 21
fi
if ! curl -fsSL "${BASE_URL}infra/deploy/fabric/powerbi_api.py" -o powerbi_api.py; then
  echo "Failed to download powerbi_api.py"
  exit 22
fi

# Try to download requirements if present
if curl -fsSL "${BASE_URL}infra/deploy/fabric/requirements.txt" -o requirements.txt; then
  if command -v python3 >/dev/null 2>&1; then
    echo "Installing Python requirements (user install)..."
    if ! python3 -m pip install --user -r requirements.txt; then
      echo "Requirements install failed"
      exit 30
    fi
  else
    echo "Python 3 not found; skipping requirements install"
  fi
fi

# Execute the create script with the provided workspace id
if command -v python3 >/dev/null 2>&1; then
  if ! python3 create_fabric_items.py --workspaceId "$WORKSPACE_ID"; then
    rc=$?
    echo "create_fabric_items.py failed with exit code $rc"
    exit 40
  fi
elif command -v python >/dev/null 2>&1; then
  if ! python create_fabric_items.py --workspaceId "$WORKSPACE_ID"; then
    rc=$?
    echo "create_fabric_items.py failed with exit code $rc"
    exit 41
  fi
else
  echo "Error: No python interpreter found. Install Python 3 or run script manually."
  exit 31
fi

echo "Deployment script finished."