cmake_minimum_required(VERSION 3.24)
# Kraskus fork: CMake 4.x removed <3.5 compatibility; the vendored cable modules and the fetched
# dependencies still declare old minimums, so builds export CMAKE_POLICY_VERSION_MINIMUM=3.5
# (docs/KRASKUS-BUILD.md).

include(cmake/cable/bootstrap.cmake)

include(CableBuildInfo)
include(CableBuildType)
include(CableToolchains)

# Kraskus fork: Hunter (the upstream package manager, pinned to Boost 1.70) cannot build with
# current compilers; dependencies now come from cmake/KraskusDependencies.cmake (Boost from a
# prefix or the system, ethash/jsoncpp/CLI11 fetched at their upstream-pinned versions).
cable_configure_toolchain(DEFAULT cxx11)

# Kraskus fork: on MSVC link the static CRT (/MT) to match the static vcpkg triplet
# (x64-windows-static builds Boost/OpenSSL with /MT); applies to CUDA host code as well.
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

project(kawpowminer LANGUAGES C CXX)
# Kraskus fork version (numeric MAJOR.MINOR.PATCH; MAJOR follows docs/ENGINE-CONTRACT.md).
set(PROJECT_VERSION 1.3.1)
set(KRASKUS_ENGINE_CONTRACT_VERSION 1)

# Current Boost and compilers: C++17 (cable's toolchain only knows cxx11; override after project()).
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Kraskus fork: the pool/API/farm code uses only the current Boost.Asio API (Boost >= 1.87
# removed the deprecated one); make older Boost versions reject deprecated calls as well so
# every build environment agrees (see docs/KRASKUS-BUILD.md).
add_definitions(-DBOOST_ASIO_NO_DEPRECATED)

# Reproducible binaries: no absolute-path-dependent timestamps in the linked output.
if (MSVC)
	add_link_options(/Brepro)
else()
	add_link_options(-Wl,--build-id=sha1)
endif()

cable_set_build_type(DEFAULT Release CONFIGURATION_TYPES Release RelWithDebInfo)

option(ETHASHCL "Build with OpenCL mining" ON)
option(ETHASHCUDA "Build with CUDA mining" ON)
option(ETHASHCPU "Build with CPU mining (only for development)" OFF)
option(ETHDBUS "Build with D-Bus support" OFF)
option(APICORE "Build with API Server support" ON)
option(DEVBUILD "Log developer metrics" OFF)

# propagates CMake configuration options to the compiler
function(configureProject)
	if (ETHASHCL)
		add_definitions(-DETH_ETHASHCL)
	endif()
	if (ETHASHCUDA)
		add_definitions(-DETH_ETHASHCUDA)
	endif()
	if (ETHASHCPU)
		add_definitions(-DETH_ETHASHCPU)
	endif()
	if (ETHDBUS)
		add_definitions(-DETH_DBUS)
	endif()
	if (APICORE)
		add_definitions(-DAPI_CORE)
	endif()
	if (DEVBUILD)
		add_definitions(-DDEV_BUILD)
	endif()
endfunction()

include(cmake/KraskusDependencies.cmake)

configureProject()

message("----------------------------------------------------------------------------")
message("-- CMake ${CMAKE_VERSION}")
message("-- Build ${CMAKE_BUILD_TYPE} / ${CMAKE_SYSTEM_NAME}")
message("----------------------------------------------------------------- components")
message("-- ETHASHCL         Build OpenCL components                      ${ETHASHCL}")
message("-- ETHASHCUDA       Build CUDA components                        ${ETHASHCUDA}")
message("-- ETHASHCPU        Build CPU components (only for development)  ${ETHASHCPU}")
message("-- ETHDBUS          Build D-Bus components                       ${ETHDBUS}")
message("-- APICORE          Build API Server components                  ${APICORE}")
message("-- DEVBUILD         Build with dev logging                       ${DEVBUILD}")
message("----------------------------------------------------------------------------")
message("")

include(EthCompilerSettings)
if(UNIX AND NOT APPLE)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libstdc++")
endif()


# Kraskus fork: build-info templates that always embed the commit (cmake/kraskus-buildinfo/README.md).
set(cable_buildinfo_template_dir ${CMAKE_CURRENT_SOURCE_DIR}/cmake/kraskus-buildinfo)
cable_add_buildinfo_library(PROJECT_NAME ${PROJECT_NAME})

add_subdirectory(libprogpow)
add_subdirectory(libdevcore)
add_subdirectory(libethcore)
add_subdirectory(libhwmon)
add_subdirectory(libpoolprotocols)

if (ETHASHCL)
	add_subdirectory(libethash-cl)
endif ()
if (ETHASHCUDA)
	add_subdirectory(libethash-cuda)
endif ()
if (ETHASHCPU)
	add_subdirectory(libethash-cpu)
endif ()
if (APICORE)
	add_subdirectory(libapicore)
endif()

add_subdirectory(kawpowminer)


if(WIN32)
	set(CPACK_GENERATOR ZIP)
else()
	set(CPACK_GENERATOR TGZ)
endif()
set(CPACK_PACKAGE_FILE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_CHECKSUM SHA256)
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY FALSE)
include(CPack)
