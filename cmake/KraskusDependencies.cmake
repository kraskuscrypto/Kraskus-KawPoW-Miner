# Kraskus fork dependency resolution (replaces Hunter).
#
# Boost: from BOOST_ROOT / Boost_ROOT (a prefix built with docs/KRASKUS-BUILD.md), a package
#        manager (vcpkg toolchain file) or the system. 1.74 or newer.
# ethash, jsoncpp, CLI11: fetched by CMake at the exact versions upstream pinned through Hunter
#        (ethash 0.5.0, jsoncpp 1.8.4, CLI11 1.8.0) so behaviour matches upstream 1.2.4; each is
#        pinned to a commit for reproducibility.

set(Boost_USE_STATIC_LIBS ON)
set(Boost_USE_MULTITHREADED ON)
find_package(Boost 1.74 REQUIRED COMPONENTS system filesystem thread)
if(NOT TARGET Boost::boost)
	add_library(Boost::boost INTERFACE IMPORTED)
	if(TARGET Boost::headers)
		target_link_libraries(Boost::boost INTERFACE Boost::headers)
	else()
		target_include_directories(Boost::boost INTERFACE ${Boost_INCLUDE_DIRS})
	endif()
endif()
message("-- Boost ${Boost_VERSION} from ${Boost_INCLUDE_DIRS}")

include(FetchContent)
set(FETCHCONTENT_QUIET OFF)

# ethash 0.5.0 (chfast/ethash tag v0.5.0): ethash::ethash, ethash::keccak
set(ETHASH_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(ETHASH_INSTALL_CMAKE_CONFIG OFF CACHE BOOL "" FORCE)
set(HUNTER_ENABLED OFF CACHE BOOL "" FORCE)
FetchContent_Declare(ethash
	GIT_REPOSITORY https://github.com/chfast/ethash.git
	GIT_TAG        v0.5.0
	GIT_SHALLOW    TRUE)

# jsoncpp 1.8.4: jsoncpp_lib_static
set(JSONCPP_WITH_TESTS OFF CACHE BOOL "" FORCE)
set(JSONCPP_WITH_POST_BUILD_UNITTEST OFF CACHE BOOL "" FORCE)
set(JSONCPP_WITH_PKGCONFIG_SUPPORT OFF CACHE BOOL "" FORCE)
set(JSONCPP_WITH_CMAKE_PACKAGE OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
FetchContent_Declare(jsoncpp
	GIT_REPOSITORY https://github.com/open-source-parsers/jsoncpp.git
	GIT_TAG        1.8.4
	GIT_SHALLOW    TRUE)

# CLI11 1.8.0 (header-only): CLI11::CLI11
set(CLI11_TESTING OFF CACHE BOOL "" FORCE)
set(CLI11_EXAMPLES OFF CACHE BOOL "" FORCE)
set(CLI11_SINGLE_FILE OFF CACHE BOOL "" FORCE)
FetchContent_Declare(CLI11
	GIT_REPOSITORY https://github.com/CLIUtils/CLI11.git
	GIT_TAG        v1.8.0
	GIT_SHALLOW    TRUE)

FetchContent_MakeAvailable(ethash jsoncpp CLI11)

# ethash exports the ethash:: namespace only from its install config; as a subproject the
# targets are plain `ethash` / `keccak`.
if(NOT TARGET ethash::ethash AND TARGET ethash)
	add_library(ethash::ethash ALIAS ethash)
endif()
if(NOT TARGET ethash::keccak AND TARGET keccak)
	add_library(ethash::keccak ALIAS keccak)
endif()
if(NOT TARGET jsoncpp_lib_static)
	# newer jsoncpp names the static target jsoncpp_static
	if(TARGET jsoncpp_static)
		add_library(jsoncpp_lib_static ALIAS jsoncpp_static)
	else()
		message(FATAL_ERROR "jsoncpp static target not found")
	endif()
endif()
# Upstream code includes <json/json.h> from libraries that do not link jsoncpp themselves
# (Hunter used to expose it globally); keep that behaviour.
include_directories(SYSTEM ${jsoncpp_SOURCE_DIR}/include)
if(NOT TARGET CLI11::CLI11 AND TARGET CLI11)
	add_library(CLI11::CLI11 ALIAS CLI11)
endif()
