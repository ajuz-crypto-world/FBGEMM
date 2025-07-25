# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_C_STANDARD_REQUIRED ON)

find_package(MKL)
if (NOT ${MKL_FOUND})
  find_package(BLAS)
endif()

if (USE_SANITIZER)
    message(WARNING "USING SANITIZER IN TEST")
endif()

if (${MKL_FOUND})
  message(STATUS "MKL_LIBRARIES= ${MKL_LIBRARIES}")
endif()

if (${BLAS_FOUND})
  message(STATUS "BLAS_LIBRARIES= ${BLAS_LIBRARIES}")
endif()

# Benchmarks
macro(add_benchmark BENCHNAME)
  add_executable(
    ${BENCHNAME}
    ${ARGN}
    BenchUtils.cc
    ../test/QuantizationHelpers.cc
    ../test/EmbeddingSpMDMTestUtils.cc
  )

  if(NOT MSVC)
    target_compile_options(
      ${BENCHNAME}
      PRIVATE
      "-m64" "-mavx2" "-mfma" "-masm=intel"
    )
  endif()

  target_link_libraries(${BENCHNAME} fbgemm)


  if(${MKL_FOUND})
    target_include_directories(${BENCHNAME} PRIVATE "${MKL_INCLUDE_DIR}")
    target_link_libraries(${BENCHNAME} "${MKL_LIBRARIES}")
    target_compile_options(${BENCHNAME} PRIVATE
      "-DUSE_MKL")
  endif()
  if (${BLAS_FOUND})
    target_compile_options(${BENCHNAME} PRIVATE "-DUSE_BLAS")
    target_link_libraries(${BENCHNAME} "${BLAS_LIBRARIES}")
  endif()

  set_target_properties(${BENCHNAME} PROPERTIES FOLDER test)
endmacro()

if(FBGEMM_BUILD_BENCHMARKS)
  set(BENCHMARKS "")

  file(GLOB BENCH_LIST "*Benchmark.cc")
  foreach(BENCH_FILE ${BENCH_LIST})
    # NOTE: Skip FP32 benchmark until FP32 is properly integrated into OSS builds
    if(BENCH_FILE MATCHES "FP32Benchmark.cc$")
      continue()
    endif()

    get_filename_component(BENCH_NAME "${BENCH_FILE}" NAME_WE)
    get_filename_component(BENCH_FILE_ONLY "${BENCH_FILE}" NAME)
    add_benchmark("${BENCH_NAME}" "${BENCH_FILE_ONLY}")
    list(APPEND BENCHMARKS "${BENCH_NAME}")
  endforeach()

  add_custom_target(run_benchmarks
    COMMAND ${BENCHMARKS})

  add_dependencies(run_benchmarks
    ${BENCHMARKS})

endif()
