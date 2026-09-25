# Qualification 1.3.0 — NVIDIA GeForce RTX 3070 Ti (Ampere, cc 8.6) — 2026-09-25

**Rig:** `kraskus-test` (Ubuntu 26.04, kernel 7.0.0-31, driver 580.178.04, CUDA toolkit 12.4.131, GCC 15.2, CMake 4.2.3, Boost 1.86 from source), i7-4790K host.
**Build:** commit `0eee1a8` (cpp-kawpow 1.1.0, CMake-native CUDA, `KRASKUS_CUDA_ARCHS` 61…90 + PTX 90, `-allow-unsupported-compiler`), `kawpowminer 1.3.0+commit.0eee1a8`, binary sha256 `e9683eb4949849a94461ded2432dabfc4ca0075792185050e3f4640206158c78` (rig build; the release hash will come from CI).
**Mode:** built-in simulation (`-Z 1000000`, no pool, no wallet): the GPU searches a synthetic KawPoW job and the CPU verifier checks every solution. Real-pool shares need a Ravencoin address from the owner (not fabricated) and are a separate step.

| Check | Result |
|---|---|
| Device enumeration | `0 01:00.0 Gpu NVIDIA GeForce RTX 3070 Ti CUDA SM 8.6 7.66 GB` (`--list-devices`) |
| DAG generation (epoch of block 1,000,000) | `Generated DAG + Light in 3,386 ms` (2.07 GB) |
| ProgPoW kernel (NVRTC, runtime) | `Pre-compiled period 333,333/333,334 CUDA ProgPow kernel for arch 8.6` (no clamp needed on CUDA 12.4) |
| Hashrate | **35.26 MH/s** steady over 7 minutes (`rtx-3070-ti-simulation-2026-09-25.log`) |
| Solutions verified by the CPU | **4 found, 4 accepted, 0 incorrect** in 7 minutes (72 s, 144 s, 226 s, 234 s) |
| Differential vs upstream 1.2.4 release binary (same GPU, same simulation, NVRTC 11.2 provided from NVIDIA's pip wheel) | upstream: 35.26 MH/s, solution accepted; fork: identical hashrate and verified solutions |
| Graceful stop | SIGINT (`timeout --signal=INT`) ends the run cleanly |

## Defect found and fixed during qualification

The first fork build (`e7a4a54`) reported `GPU 0 gave incorrect result` for every solution while hashing at the same 35.26 MH/s. Cause: the fork fetched chfast's plain **ethash 0.5.0**, but upstream's local Hunter config (`cmake/Hunter/config.cmake`) substitutes **RavenCommunity/cpp-kawpow 1.1.0**, the KawPoW-patched ethash (ProgPoW period 3, epoch length 7500) used by the CPU verifier. With cpp-kawpow the verifier agrees with the GPU (`0eee1a8`).

## Not covered yet

- Real pool shares (needs an RVN address and a pool choice from the owner).
- GTX 1070 (Pascal) and RTX 5070 (Blackwell): separate hardware gates. Blackwell on CUDA 12.4 will use the NVRTC clamp (compute_90 PTX); native `sm_120` needs the CUDA 12.8 CI build.
- Windows x64 binary: built by CI (vcpkg Boost), not yet run on a Windows GPU.
