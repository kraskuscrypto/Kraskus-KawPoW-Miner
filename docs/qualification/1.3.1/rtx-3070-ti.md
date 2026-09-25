# 1.3.1 — RTX 3070 Ti (kraskus-test-rig), release binary, 2026-09-25

**Release:** tag `v1.3.1` = commit `4c34661aa2c33b09e58908f702870ffba561a279`, built by the release workflow (run 36184911646: ubuntu-22.04 + CUDA 12.4.1 / 12.8.0, windows-2022 + CUDA 12.8.0 + vcpkg Boost 1.92.0 static). Repository public; assets downloadable anonymously (checked with plain `curl`, no token, HTTP 200).

**Hashes (published `SHA256SUMS`, recomputed independently on the workstation and on the rig, and equal to the build jobs' own artefacts):**

| Asset | SHA-256 |
|---|---|
| `kraskus-kawpowminer-1.3.1-linux-x64.tar.gz` (CUDA 12.4 build, the registry artefact) | `f7638865ae27067a9e9724958598f17b3daa72f118b6ff0e22f8d66123b53139` |
| `kraskus-kawpowminer-1.3.1-linux-x64-cuda12.8.tar.gz` | `9516912fab5487e9f0b6bbde3798409bba21972b11fa4d70aac450dda29f2b6b` |
| `kraskus-kawpowminer-1.3.1-windows-x64.zip` | `d9ff56cfd1ee5019f7dce44de76b2c5195308ac22bed4c4398133001603f402b` |
| extracted `kawpowminer` (linux-x64) | `7c3e394dbec76caea435d3a233ca3176a61fa47ef535f63fb44a76d61d1958a8` |
| extracted `kawpowminer.exe` (windows-x64) | `f945007026d4c080824b562cd4b39e99309444befe473ae52bebf7b69d9fd11d` |

**Rig:** Ubuntu 26.04, driver 580.178.04, NVIDIA GeForce RTX 3070 Ti (`GPU-8debc260-17d3-e634-7c4a-b13863eb0be2`, PCI `00000000:01:00.0`, cc 8.6). The release binary (not a rig build) was downloaded anonymously, hash-checked against `SHA256SUMS`, extracted and run:

- `test/contract/run.sh <release binary> 60`: **10 passed, 0 failed** — version line `kawpowminer 1.3.1+commit.4c34661a`, device table, identity line, speed/job/DAG/NVRTC lines, no incorrect results, `miner_getstat1`.
- Simulation mode (`-Z 1000000`, rig build of the same commit, same GPU): 35.26 MH/s steady, unchanged from 1.3.0 (`../1.3.0/rtx-3070-ti.md`).

**Not yet done:** real-pool run (needs the owner's Ravencoin address and pool; driven by the Universal Miner's `tests/acceptance/run-kawpow-acceptance.sh`), a Windows GPU run, GTX 1070 / RTX 5070.

**1.3.0:** superseded. Its release binaries printed the bare `kawpowminer 1.3.0` (cable's build-info drops `+commit.<sha8>` on a tag checkout) and failed the contract's version-line check; 1.3.1 changes only the build-info templates (`cmake/kraskus-buildinfo/`).
