# Upstream provenance

This repository is a fork of **kawpowminer** by the Ravencoin community, itself derived from
ethminer / progminer (GPL-3.0). Kraskus maintains it as the open, fee-free, redistributable
KawPoW engine for the Kraskus Universal Miner.

| | |
|---|---|
| Upstream repository | https://github.com/RavenCommunity/kawpowminer |
| Forked at commit | `632f6ea0a5cd09e2c6443374dbe6db0a767715ba` (2021-06-15, "Fix in issue #42 ... (#90)") |
| Upstream version at fork | 1.2.4 (tag `1.2.4`; the fork keeps every upstream tag and the full history) |
| Fork date | 2026-09-25 |
| License | GNU General Public License v3.0 (`LICENSE`, unchanged). Every Kraskus modification is released under the same license. Binaries are distributed together with a pointer to the exact source tag they were built from. |
| Upstream remote in the working copy | `upstream` -> https://github.com/RavenCommunity/kawpowminer |

## Merging upstream changes

```bash
git fetch upstream
git merge upstream/master      # then re-run docs/KRASKUS-BUILD.md on both platforms and the engine-contract tests
```

Upstream has been inactive since 2021; merges are expected to be rare. Kraskus-specific work
lives in ordinary commits on `main`; there is no separate patch queue.

## What Kraskus changes (summary; see CHANGELOG.md for detail)

- Build: CMake >= 3.24, native CUDA language support, explicit `KRASKUS_CUDA_ARCHS`
  (Pascal `61` through Blackwell `120`, PTX forward-compatibility), current compilers.
- NVRTC: the runtime-compiled ProgPoW kernel targets the highest architecture the installed
  NVRTC supports when the GPU is newer than the toolkit (e.g. Blackwell with CUDA 12.4).
- Engine contract: stable command line, config and telemetry/API surface documented in
  `docs/ENGINE-CONTRACT.md`, consumed by the Universal Miner's declarative adapter.
- Releases: versioned artefacts for `windows-x64` and `linux-x64` with `SHA256SUMS`
  (`docs/RELEASE.md`); reproducible build instructions (`docs/KRASKUS-BUILD.md`).
- **No mining fee of any kind** (upstream had none; none will be added).
