# A custom command and target to turn the CUDA kernel into a byte array header
# The normal build depends on it properly and if the kernel file is changed, then
# a rebuild of libethash-cuda should be triggered

add_custom_command(
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/CUDAMiner_kernel.h
	COMMAND ${CMAKE_COMMAND} ARGS
	-DTXT2STR_SOURCE_FILE="${CMAKE_CURRENT_SOURCE_DIR}/CUDAMiner_kernel.cu"
	-DTXT2STR_VARIABLE_NAME=CUDAMiner_kernel
	-DTXT2STR_HEADER_FILE="${CMAKE_CURRENT_BINARY_DIR}/CUDAMiner_kernel.h"
	-P "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/txt2str.cmake"
	COMMENT "Generating CUDA Kernel"
	DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/CUDAMiner_kernel.cu
)
add_custom_target(cuda_kernel DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/CUDAMiner_kernel.h ${CMAKE_CURRENT_SOURCE_DIR}/CUDAMiner_kernel.cu)

# ---- Kraskus fork: CUDA through CMake's native language support ----------------------------
# FindCUDA / cuda_add_library are deprecated (removed in CMake 4); the static part of the miner
# (CUDAMiner_cuda.cu) is compiled by nvcc for the KRASKUS_CUDA_ARCHS list with PTX for the
# highest entry, and the ProgPoW kernel is compiled at runtime by NVRTC (CUDAMiner.cpp).
enable_language(CUDA)
find_package(CUDAToolkit REQUIRED)

message("")
message("----------------------------------------------------------------------------")
message("-- Detected CUDA Toolkit: ${CUDAToolkit_VERSION} (${CUDAToolkit_NVCC_EXECUTABLE})")
if(NOT DEFINED KRASKUS_CUDA_ARCHS)
	set(KRASKUS_CUDA_ARCHS "61;70;75;80;86;89;90")
	if(CUDAToolkit_VERSION VERSION_GREATER_EQUAL 12.8)
		list(APPEND KRASKUS_CUDA_ARCHS "100" "120")
	endif()
endif()
list(GET KRASKUS_CUDA_ARCHS -1 KRASKUS_CUDA_ARCH_MAX)
set(_kraskus_archs "")
foreach(arch ${KRASKUS_CUDA_ARCHS})
	list(APPEND _kraskus_archs "${arch}-real")
endforeach()
list(APPEND _kraskus_archs "${KRASKUS_CUDA_ARCH_MAX}-virtual")
set(CMAKE_CUDA_ARCHITECTURES ${_kraskus_archs})
message("-- Kraskus CUDA archs: ${CMAKE_CUDA_ARCHITECTURES}")
message("----------------------------------------------------------------------------")
message("")

file(GLOB sources CUDAMiner.cpp CUDAMiner_cuda.cu)
file(GLOB headers CUDAMiner.h CUDAMiner_cuda.h ${CMAKE_CURRENT_BINARY_DIR}/CUDAMiner_kernel.h)

add_library(ethash-cuda STATIC ${sources} ${headers})
add_dependencies(ethash-cuda cuda_kernel)
target_compile_options(ethash-cuda PRIVATE
	$<$<COMPILE_LANGUAGE:CUDA>:--ptxas-options=-v>
	$<$<COMPILE_LANGUAGE:CUDA>:-lineinfo>
	$<$<COMPILE_LANGUAGE:CUDA>:-use_fast_math>
	$<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:Release>>:-O3>
	$<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:Debug>>:-G>)
if(NOT MSVC)
	target_compile_options(ethash-cuda PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:--disable-warnings>)
endif()
target_link_libraries(ethash-cuda ethcore ethash::ethash progpow Boost::thread)
target_link_libraries(ethash-cuda CUDA::nvrtc CUDA::cuda_driver CUDA::cudart_static)
target_include_directories(ethash-cuda PUBLIC ${CUDAToolkit_INCLUDE_DIRS})
target_include_directories(ethash-cuda PRIVATE .. ${CMAKE_CURRENT_BINARY_DIR})
