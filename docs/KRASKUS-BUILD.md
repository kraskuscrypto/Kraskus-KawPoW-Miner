# Reproducible build

## Toolchain (pinned)

| | Linux x64 | Windows x64 |
|---|---|---|
| OS image | Ubuntu 22.04 (CI) / Ubuntu 26.04 (rig) | Windows Server 2022 (CI) / Windows 11 |
| Compiler | GCC 11–13 (CUDA 12.4 supports up to GCC 13; newer hosts pass `-allow-unsupported-compiler`) | MSVC 2022 (v143) |
| CUDA toolkit | 12.4 for `sm_61…sm_90` (+PTX); **12.8 or newer for native `sm_100`/`sm_120`** | same |
| CMake | >= 3.24 (CMake 4.x works with `-DCMAKE_POLICY_VERSION_MINIMUM=3.5` for the vendored Hunter/cable modules until they are replaced) | same |
| Dependencies | Boost, jsoncpp, ethash via Hunter (pinned by SHA1 in `CMakeLists.txt`; the Hunter archive itself is pinned) | same |

## Commands

```bash
git clone https://github.com/kraskuscrypto/Kraskus-KawPoW-Miner.git && cd Kraskus-KawPoW-Miner
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DETHASHCUDA=ON -DETHASHCL=OFF -DAPICORE=ON \
      -DKRASKUS_CUDA_ARCHS="61;70;75;80;86;89;90" -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build --config Release --parallel
./build/kawpowminer/kawpowminer --version
```

Windows: run from a "x64 Native Tools" prompt with `-G "Visual Studio 17 2022" -A x64`. Set
`-DKRASKUS_CUDA_ARCHS="61;70;75;80;86;89;90;100;120"` when building with CUDA >= 12.8 (the
default list adds `100;120` automatically when the toolkit is new enough).

`KRASKUS_CUDA_ARCHS` accepts CMake's `CMAKE_CUDA_ARCHITECTURES` syntax; the highest entry is
also emitted as PTX so newer GPUs JIT-compile the static kernels. The ProgPoW kernel itself is
compiled at runtime with NVRTC for the device's architecture, clamped to the toolkit's highest
supported architecture (`libethash-cuda/CUDAMiner.cpp`).

## Determinism

Release builds are done in CI from a tag, with the toolchain versions above logged into the
build output that is attached to the release. Two builds from the same tag on the same image
must produce identical `--version` output and the same `SHA256SUMS` for the packaged binaries
apart from PE/ELF timestamps (`/Brepro` on MSVC and `-Wl,--build-id=sha1` on Linux are set in
CMake for that reason).
