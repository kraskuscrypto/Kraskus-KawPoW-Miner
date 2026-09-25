# Reproducible build (Kraskus fork)

Upstream's own notes are in `docs/BUILD.md`; this file is the authoritative procedure for Kraskus releases.

## Toolchain (pinned)

| | Linux x64 | Windows x64 |
|---|---|---|
| OS image | Ubuntu 22.04 (CI) / Ubuntu 26.04 (RTX 3070 Ti rig) | Windows Server 2022 (CI) / Windows 11 |
| Compiler | GCC 11–13 (CUDA 12.4 supports up to GCC 13; newer hosts pass `-allow-unsupported-compiler`) | MSVC 2022 (v143) |
| CUDA toolkit | 12.4 for `sm_61…sm_90` (+PTX); **12.8 or newer for native `sm_100`/`sm_120`** | same |
| CMake | >= 3.24 (CMake 4.x works with `CMAKE_POLICY_VERSION_MINIMUM=3.5` exported for the vendored cable modules and the fetched dependencies) | same |
| Boost | >= 1.74, static (the pool/API/farm code uses the current Asio API: `io_context`, `strand<executor>`, `bind_executor`, `post`, resolver `results_type`; verified with 1.86 on the rig and 1.92 via vcpkg in CI): `system`, `filesystem`, `thread` plus headers (asio, algorithm, lexical_cast, bind, lockfree, dll, smart_ptr, process, multiprecision, format, exception, array). From a prefix (`BOOST_ROOT`), a package manager (vcpkg toolchain) or the distribution. | vcpkg `x64-windows-static` ports (see CI) |
| ethash (RavenCommunity/cpp-kawpow), jsoncpp, CLI11 | fetched by CMake (`cmake/KraskusDependencies.cmake`) at upstream's pinned versions **cpp-kawpow 1.1.0 (the KawPoW-patched ethash) / 1.8.4 / 1.8.0** | same |
| OpenSSL | development package (stratum+ssl) | vcpkg `openssl` |

Hunter (upstream's package manager) is no longer used: its pinned Boost 1.70 does not compile with current compilers.

## Commands (Linux)

```bash
git clone --recurse-submodules https://github.com/kraskuscrypto/Kraskus-KawPoW-Miner.git && cd Kraskus-KawPoW-Miner   # cmake/cable is a submodule

# Boost without root (e.g. the rig): build 1.86 into $HOME/deps once
#   curl -sSLo boost.tgz https://archives.boost.io/release/1.86.0/source/boost_1_86_0.tar.gz   # sha256 2575e74ffc3ef1cd0babac2c1ee8bdb5782a0ee672b1912da40e5b4b591ca01f
#   tar xzf boost.tgz && cd boost_1_86_0
#   ./bootstrap.sh --prefix=$HOME/deps --with-libraries=system,filesystem,thread && ./b2 -j8 link=static cxxstd=17 install

export CMAKE_POLICY_VERSION_MINIMUM=3.5   # environment, not only -D: the fetched dependencies configure nested projects
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DETHASHCUDA=ON -DETHASHCL=OFF -DAPICORE=ON \
      -DBOOST_ROOT=$HOME/deps -DKRASKUS_CUDA_ARCHS="61;70;75;80;86;89;90" \
      -DCMAKE_CUDA_FLAGS="-allow-unsupported-compiler"   # only when the host compiler is newer than the toolkit supports
cmake --build build --config Release --parallel
./build/kawpowminer/kawpowminer --version
```

## Commands (Windows)

From a "x64 Native Tools Command Prompt for VS 2022":

```bat
set CMAKE_POLICY_VERSION_MINIMUM=3.5
git clone https://github.com/microsoft/vcpkg.git %USERPROFILE%\vcpkg && git -C %USERPROFILE%\vcpkg checkout 10541e317a660f4165ba4ac2851ab54a8d4577b1 && %USERPROFILE%\vcpkg\bootstrap-vcpkg.bat -disableMetrics
set VCPKG_ROOT=%USERPROFILE%\vcpkg
rem vcpkg.json (manifest mode) pins the baseline (currently Boost 1.92.0 + OpenSSL 3.6.4); they are built into build\vcpkg_installed during configure
cmake -S . -B build -G "Visual Studio 17 2022" -A x64 -DETHASHCUDA=ON -DETHASHCL=OFF -DAPICORE=ON ^
      -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows-static
cmake --build build --config Release --parallel
build\kawpowminer\Release\kawpowminer.exe --version
```

Add `-DKRASKUS_CUDA_ARCHS="61;70;75;80;86;89;90;100;120"` explicitly when building with CUDA >= 12.8 for native Blackwell code (the default list adds `100;120` automatically when the toolkit is new enough).

`KRASKUS_CUDA_ARCHS` feeds `CMAKE_CUDA_ARCHITECTURES` (`<arch>-real` for each entry plus `<max>-virtual` PTX so newer GPUs JIT-compile the static kernels). The ProgPoW kernel itself is compiled at runtime with NVRTC for the device's architecture, clamped to the toolkit's highest supported architecture (`libethash-cuda/CUDAMiner.cpp`).

## Determinism

Release builds are done in CI from a tag, with the toolchain versions above logged into the build output that is attached to the release. Two builds from the same tag on the same image must produce identical `--version` output and the same `SHA256SUMS` for the packaged binaries apart from PE/ELF timestamps (`/Brepro` on MSVC and `-Wl,--build-id=sha1` on Linux are set in CMake for that reason). The fetched dependencies are pinned to tags; pinning them to commit hashes is a follow-up before the first tagged release.
