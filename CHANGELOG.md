## 1.3.0 (Kraskus fork, in progress, 2026-09-25)

- Forked from RavenCommunity/kawpowminer 1.2.4 (`632f6ea`, 2021-06-15). GPL-3.0 unchanged. No fee.
- Build: Hunter removed (its pinned Boost 1.70 no longer compiles); Boost from a prefix/system, cpp-kawpow 1.1.0 (KawPoW-patched ethash) / jsoncpp 1.8.4 / CLI11 1.8.0 fetched by CMake at upstream's pinned versions; CUDA through CMake's native language support (FindCUDA removed); C++17. CMake >= 3.24; explicit `KRASKUS_CUDA_ARCHS` (61,70,75,80,86,89,90 + 100,120 on CUDA >= 12.8) with PTX for the highest; reproducible link flags.
- NVRTC: runtime ProgPoW kernel target clamped to the highest architecture the installed NVRTC supports (newer GPUs JIT from PTX instead of failing).
- Docs: UPSTREAM.md, AGENTS.md, docs/ENGINE-CONTRACT.md, docs/KRASKUS-BUILD.md, docs/RELEASE.md; CI for linux-x64 (CUDA 12.4 and 12.8) and windows-x64 (CUDA 12.8) with hashed artefacts.
- Qualification on the RTX 3070 Ti rig (simulation mode): 35.26 MH/s, 4/4 solutions verified, identical to upstream 1.2.4 on the same GPU (`docs/qualification/1.3.0/`). Defect fixed on the way: the CPU verifier must use cpp-kawpow, not plain ethash.
- Engine contract: `[kraskus] device <ordinal> pci <addr> uuid <GPU-...> name <...> cc <cc>` identity line (matches nvidia-smi on the rig); `test/contract/run.sh` (10/10 on the RTX 3070 Ti).
- Boost.Asio port: pool clients (stratum, getwork), API server, farm and CLI now use `io_context`, `strand<io_context::executor_type>`, `bind_executor`, `boost::asio::post` and the resolver `results_type` API (required by Boost >= 1.87). Windows: vcpkg manifest (`vcpkg.json`) pinned to a current baseline (Boost 1.92.0 / OpenSSL 3.6.4), static x64.
- Pending: real-pool shares (RVN address needed), Windows GPU run, GTX 1070 / RTX 5070 gates.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## 0.16.1rc0

### Fixed

- Display interval correction [#1606](https://github.com/ethereum-mining/ethminer/pull/1606)

## 0.16.0rc0

### Fixed

- Eliminated duplicate solutions with stratum2 on difficulty changes.
- Restored proper behavior of `-P` argument to identify workernames and emails

### Added

- Basic API authentication to protect exposure of API port to the internet [#1228](https://github.com/ethereum-mining/ethminer/pull/1228).
- Add `ispaused` information into response of `miner_getstathr` API query [#1232](https://github.com/ethereum-mining/ethminer/pull/1232).
- API responses return "ethminer-" as version prefix. [#1300](https://github.com/ethereum-mining/ethminer/pull/1300).
- Stratum mode autodetection. No need to specify `stratum+tcp` or `stratum1+tcp` or `stratum2+tcp`
- Connection failed due to login errors (wrong address or worker) are marked Unrecoverable and no longer used
- Replaced OpenCL kernel with opensource jawawawa OpenCL kernel
- Added support for jawawawa AMD binary kernels
- AMD auto kernel selection. Try bin first, if not fall back to OpenCL.
- API: New method `miner_setverbosity`. [#1382](https://github.com/ethereum-mining/ethminer/pull/1382).
- Implemented fast job switch algorithm on AMD reducing switch time to 1-2 milliseconds.
- Added localization support for output number formatting.
- Changed the --verbosity option to allow individual enable/disable of logging features.
- Improved hash rate measurement accuracy.

### Removed

- Command line argument `--stratum-email`: any information needed to authenticate on the pool **MUST BE** set using the `-P` argument

## 0.15.0rc1

### Fixed

- Restore the ability to auto-config OpenCL work size [#1225](https://github.com/ethereum-mining/ethminer/pull/1225).
- The API server totally broken fixed [#1227](https://github.com/ethereum-mining/ethminer/pull/1227).


## 0.15.0rc0

### Added

- Add `--tstop` and `--tstart` option preventing GPU overheating [#1146](https://github.com/ethereum-mining/ethminer/pull/1146), [#1159](https://github.com/ethereum-mining/ethminer/pull/1159).
- Added information about ordering CUDA devices in the README.md FAQ [#1162](https://github.com/ethereum-mining/ethminer/pull/1162).

### Fixed

- Reconnecting with mining pool improved [#1135](https://github.com/ethereum-mining/ethminer/pull/1135).
- Stratum nicehash. Avoid recalculating target with every job [#1156](https://github.com/ethereum-mining/ethminer/pull/1156).
- Drop duplicate stratum jobs (pool bug workaround) [#1161](https://github.com/ethereum-mining/ethminer/pull/1161).
- CLI11 command line parsing support added [#1160](https://github.com/ethereum-mining/ethminer/pull/1160).
- Farm mode (get_work): fixed loss of valid shares and increment in stales [#1215](https://github.com/ethereum-mining/ethminer/pull/1215).
- Stratum implementation improvements [#1222](https://github.com/ethereum-mining/ethminer/pull/1222).
- Build fixes & improvements [#1214](https://github.com/ethereum-mining/ethminer/pull/1214).

### Removed

- Disabled Debug configuration for Visual Studio [#69](https://github.com/ethereum-mining/ethminer/issues/69) [#1131](https://github.com/ethereum-mining/ethminer/pull/1131).
