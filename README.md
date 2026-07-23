# trust-registry-image

Container image for the [Affinidi Trust Registry](https://github.com/FirstPersonNetwork/affinidi-trust-registry-rs),
using the embedded **fjall** storage backend (single-node, on-disk, no external database).

The image downloads a prebuilt `trust-registry` binary at build time from
`https://fpp.ic3.dev/trust-registry-k8s/<version>/trust-registry` and runs it via
[`entrypoint.sh`](./entrypoint.sh).

## Build

```bash
docker build --build-arg TRUST_REGISTRY_VERSION=0.8.0 -t trust-registry:0.8.0 .
```

The GitHub Actions workflow ([`.github/workflows/build.yml`](./.github/workflows/build.yml))
builds and pushes to `ghcr.io/<owner>/trust-registry` on manual dispatch.

## Run

REST-only (simplest — no DIDComm identity required):

```bash
docker run --rm -p 3232:3232 \
  -e ENABLE_DIDCOMM=false \
  -v trust-registry-data:/app/trust-registry/data \
  trust-registry:0.8.0
```

The Trust Registry listens on `0.0.0.0:3232`. Mount a volume/PVC at
`/app/trust-registry/data` to persist the fjall keyspace across restarts.

## Environment variables

The entrypoint sets fjall defaults; everything else is passed through to the binary.

| Variable             | Default (in image)            | Notes                                                             |
| -------------------- | ----------------------------- | ----------------------------------------------------------------- |
| `TR_STORAGE_BACKEND` | `fjall`                       | Storage backend for trust records.                                |
| `TR_FJALL_PATH`      | `/app/trust-registry/data`    | Directory for the embedded fjall keyspace. Mount to persist.      |
| `LISTEN_ADDRESS`     | `0.0.0.0:3232` (binary)       | Bind address for the REST/TRQP surface.                           |
| `RUST_LOG`           | unset ⇒ `error` only          | Not set by the image. Set `RUST_LOG=info` (e.g. in K8s) for info logs. |
| `ENABLE_REST`        | `true` (binary)               | Serve TRQP over REST.                                             |
| `ENABLE_DIDCOMM`     | `true` (binary)               | DIDComm listener. Requires `PROFILE_CONFIG` + `MEDIATOR_DID`.     |

When `ENABLE_DIDCOMM` is enabled (its default) but `PROFILE_CONFIG` is unset, the
container prints instructions and holds instead of crash-looping. Provide a
`PROFILE_CONFIG` (DID + secrets) and `MEDIATOR_DID` / `ADMIN_DIDS`, or set
`ENABLE_DIDCOMM=false` to run REST-only.

See the upstream
[README environment-variables section](https://github.com/FirstPersonNetwork/affinidi-trust-registry-rs#environment-variables)
for the full list.
