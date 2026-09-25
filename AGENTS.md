# Kraskus-KawPoW-Miner — agent instructions

You are working in the Kraskus fork of kawpowminer (GPLv3). Read `UPSTREAM.md`,
`docs/ENGINE-CONTRACT.md`, `docs/KRASKUS-BUILD.md` and `docs/RELEASE.md` before changing anything.

## Non-negotiable rules

1. **GPLv3 stays.** Never relicense, never add non-GPL-compatible code, never strip copyright
   headers. Every release ships (or links) the exact source tag.
2. **No mining fee.** No dev fee, no donation rounds, no hidden pool switching. A change that
   adds one is rejected.
3. **Consensus code is not ours to change.** ProgPoW/KawPoW parameters (`libprogpow`,
   `libethash-cuda/CUDAMiner_kernel.cu` math, period/epoch constants) change only to track a
   Ravencoin network change, with a reference to the network announcement.
4. **The engine contract is stable.** Changing a command-line option, output line format,
   config key or API method documented in `docs/ENGINE-CONTRACT.md` is a breaking change:
   bump the major version and update the Universal Miner manifest in the same release.
5. **Reproducible builds.** Pinned toolchain versions and dependency hashes in
   `docs/KRASKUS-BUILD.md` and CI; artefacts are hashed (`SHA256SUMS`) and versioned.
6. **Targets:** Pascal (GTX 1070, `sm_61`), Ampere (RTX 3070 Ti, `sm_86`), Blackwell
   (RTX 5070, `sm_120`) on Windows x64 and Linux x64. The RTX 3070 Ti rig is the first real
   qualification target; GTX 1070 and RTX 5070 are separate later gates.
7. This repository never becomes a dependency of the Universal Miner core: the core consumes
   release artefacts through its signed registry only. No KawPoW/CUDA code goes into the core.

## Working rules

- Small commits; run the build on the platform you touched; record real-GPU results under
  `docs/qualification/`.
- Keep GMiner out of scope here; it is an optional, disabled-by-default engine on the
  Universal Miner side and is never required.
