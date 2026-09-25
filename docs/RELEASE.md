# Releases

1. Bump `PROJECT_VERSION` in `CMakeLists.txt` (numeric `MAJOR.MINOR.PATCH`), update
   `CHANGELOG.md`, tag `v<version>`.
2. CI (`.github/workflows/build.yml`, `release` job on tags) builds `linux-x64` and
   `windows-x64`, packages them as
   `kraskus-kawpowminer-<version>-linux-x64.tar.gz` and
   `kraskus-kawpowminer-<version>-windows-x64.zip` (layout
   `kraskus-kawpowminer-<version>/kawpowminer[.exe]`, so the Universal Miner uses
   `strip_components: 1`), writes `SHA256SUMS`, and attaches everything plus the source
   archive to the GitHub release.
3. `SHA256SUMS` is signed by the Kraskus **online engine key** (registry key hierarchy) as
   `SHA256SUMS.sig` in a separate, owner-run step; the Universal Miner manifest carries the
   package hashes, the executable hash, and the signing-key fingerprint, and verifies the
   signature in-app before every install (`upstream_signature.type = sha256sums-signed`).
4. Qualification evidence for the release lives in `docs/qualification/<version>/` (RTX 3070
   Ti first; GTX 1070 and RTX 5070 as they become available): hashrate, accepted shares,
   graceful stop, device identity line, driver version.
