#!/bin/sh
set -e

DATA_DIR="/app/trust-registry/data"

# --- Embedded fjall storage defaults (override via env) ---------------------
# fjall is a single-node, on-disk LSM store that needs no external database.
# The keyspace directory is created on first start; mount a volume/PVC at
# TR_FJALL_PATH to persist trust records across restarts.
export TR_STORAGE_BACKEND="${TR_STORAGE_BACKEND:-fjall}"
export TR_FJALL_PATH="${TR_FJALL_PATH:-$DATA_DIR}"

mkdir -p "$TR_FJALL_PATH"

# --- DIDComm requires an identity profile -----------------------------------
# ENABLE_DIDCOMM defaults to true in the binary. When enabled, the registry
# loads its DID profile on the DIDComm path and cannot start without a
# PROFILE_CONFIG (DID + secrets). Hold the container with a clear message
# instead of crash-looping, mirroring how vta waits for its setup.
if [ "${ENABLE_DIDCOMM:-true}" != "false" ] && [ -z "$PROFILE_CONFIG" ]; then
  echo "⚠️  DIDComm is enabled but PROFILE_CONFIG is not set."
  echo "👉 Provide PROFILE_CONFIG (and MEDIATOR_DID / ADMIN_DIDS),"
  echo "   or run REST-only with ENABLE_DIDCOMM=false."
  echo "⏳ Holding container..."
  sleep infinity
fi

echo "✅ Storage backend: $TR_STORAGE_BACKEND (fjall path: $TR_FJALL_PATH)"
echo "🚀 Starting trust-registry..."
exec trust-registry
