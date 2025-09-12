# Deploy Fabric Resources Script
# To set up Python environment and deploy Fabric resources using the provided script.

set -e

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <baseUrl> <fabricWorkspaceId>"
  echo "Example: $0 \"https://raw.githubusercontent.com/microsoft/unified-data-foundation-with-fabric-solution-accelerator/main/\" "
  exit 1
fi

BASE_URL="$1"
WORKSPACE_ID="$2"

# Ensure trailing slash
if [[ "${BASE_URL: -1}" != "/" ]]; then
  BASE_URL="${BASE_URL}/"
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

cd "$TMP_DIR"

echo "Working directory: $TMP_DIR"
echo "Downloading deployment artifacts from $BASE_URL"

curl -fsSL "${BASE_URL}infra/deploy/fabric/create_fabric_items.py" -o create_fabric_items.py
curl -fsSL "${BASE_URL}infra/deploy/fabric/fabric_api.py" -o fabric_api.py || true
curl -fsSL "${BASE_URL}infra/deploy/fabric/powerbi_api.py" -o powerbi_api.py || true

# Try to download requirements if present
if curl -fsSL "${BASE_URL}infra/deploy/fabric/requirements.txt" -o requirements.txt; then
  if command -v python3 >/dev/null 2>&1; then
    echo "Installing Python requirements (user install)..."
    python3 -m pip install --user -r requirements.txt || true
  else
    echo "Python 3 not found; skipping requirements install"
  fi
fi

# Execute the create script with the provided workspace id
if command -v python3 >/dev/null 2>&1; then
  python3 create_fabric_items.py --workspaceId "$WORKSPACE_ID"
elif command -v python >/dev/null 2>&1; then
  python create_fabric_items.py --workspaceId "$WORKSPACE_ID"
else
  echo "Error: No python interpreter found. Install Python 3 or run script manually."
  exit 2
fi

echo "Deployment script finished."