# Copyright 2021 Edouard Gomez <ed.gomez@free.fr>
# SPDX-License-Identifier: MIT
#
# Inspect variable values within a dummy project setup exactly like
# the current one w.r.t anything that impacts the targeted
# system/architecture
#
# Tested in multiple configurations, not guaranteed to work in all cases
#  - windows programs using regular VStudio+MSVC combo
#  - linux programs using Ninja/Ninja Multi-Config/GNU Makefiles
#    generators + env vars or toolchain files
#  - android programs/libs Ninja/Ninja Multi-Config/GNU Makefiles
#    generators + ndk toolchain file + cmake special ANDROID_XXX variables
#
# Works great with toolchain files as these bring almost everything required
# by the spawned cmake.
#
# Env vars like C/CXX/CXXFLAGS are inherited by the spawned cmake process so
# these should be covered too.
#
# Handles as many cmake options as possible that impact the resulting
# target platform or generator. Here some could be missed, feel free to
# add more
if (TargetInspector_INCLUDED)
  return()
endif()

set(TargetInspector_DIR "${CMAKE_CURRENT_LIST_DIR}")

# @param INSPECT_VARIABLE[list] List of variables names to inspect in the context of the targeted cmake configuration
# @param OUTPUT_VARNAME[list] List of variables names to create in PARENT_SCOPE with the inspected values
function(target_inspect)
  cmake_parse_arguments(__ti "" "" "INSPECT_VARIABLE;OUTPUT_VARNAME" ${ARGN})

  set(TI_DIR "${CMAKE_BINARY_DIR}/TargetInspector")
  get_filename_component(TI_DIR_ABSOLUTE "${TI_DIR}" ABSOLUTE)

  # Prepare a cmake call that will use as many options/variables
  # that influence the resulting platform detection
  set(__cmake_call)
  list(APPEND __cmake_call "${CMAKE_COMMAND}" "-B" "${TI_DIR_ABSOLUTE}/build")
  if (CMAKE_GENERATOR)
    list(APPEND __cmake_call "-G" "${CMAKE_GENERATOR}")
  endif()
  if (CMAKE_GENERATOR_PLATFORM)
    list(APPEND __cmake_call "-A" "${CMAKE_GENERATOR_PLATFORM}")
  endif()
  if (CMAKE_MAKE_PROGRAM)
    get_filename_component(CMAKE_MAKE_PROGRAM_ABSOLUTE "${CMAKE_MAKE_PROGRAM}" PROGRAM)
    list(APPEND __cmake_call "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM_ABSOLUTE}")
  endif()
  if (CMAKE_TOOLCHAIN_FILE)
    get_filename_component(CMAKE_TOOLCHAIN_FILE_ABSOLUTE "${CMAKE_TOOLCHAIN_FILE}" ABSOLUTE)
    list(APPEND __cmake_call "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE_ABSOLUTE}") 
  endif()
  if (CMAKE_GENERATOR_TOOLSET)
    list(APPEND __cmake_call "-T" "${CMAKE_GENERATOR_TOOLSET}")
  endif()
  if (CMAKE_GENERATOR_INSTANCE)
    list(APPEND __cmake_call "-DCMAKE_GENERATOR_INSTANCE=${CMAKE_GENERATOR_INSTANCE}")
  endif()
  if (_CMAKE_TOOLCHAIN_PREFIX)
    list(APPEND __cmake_call "-D_CMAKE_TOOLCHAIN_PREFIX=${_CMAKE_TOOLCHAIN_PREFIX}")
  endif()
  # The android toochain requires a lot of attention
  foreach (var NDK ABI ALLOW_UNDEFINED_SYMBOLS APP_PIE ARM_MODE ARM_NEON CCACHE CPP_FEATURES DISABLE_FORMAT_STRING_CHECKS NATIVE_API_LEVEL PLATFORM STL TOOLCHAIN_NAME)
    if (ANDROID_${var})
      list(APPEND __cmake_call "-DANDROID_${var}=${ANDROID_${var}}")
    endif()
  endforeach()
  # of course you can extend the cmake variables required here.
  list(APPEND __cmake_call "${TI_DIR_ABSOLUTE}")

  # Generate the CMakeLists.txt that will be in charge of inspecting the
  # requested variables
  file(MAKE_DIRECTORY "${TI_DIR}")
  configure_file("${TargetInspector_DIR}/TargetInspector.CMakeLists.txt.in" "${TI_DIR}/CMakeLists.txt" @ONLY)

  # log the cmake call in the Generated CMakeList.txt for debug purposes
  set(__cmake_call_quoted)
  foreach(o IN LISTS __cmake_call)
    list(APPEND __cmake_call_quoted "\"${o}\"")
  endforeach()
  string(REPLACE ";" " " __cmake_call_spaced "${__cmake_call_quoted}")
  file(APPEND "${TI_DIR_ABSOLUTE}/CMakeLists.txt" "# " "${__cmake_call_spaced}")

  # configure the dummy project
  execute_process(
    COMMAND
      ${__cmake_call}
    OUTPUT_VARIABLE
      TI_OUTPUT
    RESULT_VARIABLE
      TI_SUCCESS
  )

  if (NOT TI_SUCCESS EQUAL 0)
    message(FATAL_ERROR "
Could not configure a dummy project to inspect the variables within the target
environment.

The dummy project can be found in the directory \"${TI_DIR_ABSOLUTE}\"

Command to reproduce the dummy project configuration:
${__cmake_call_spaced}
"
  )
  endif()

  foreach(ovarname IN LISTS __ti_OUTPUT_VARNAME)
    file(READ "${TI_DIR_ABSOLUTE}/reply/v1/${ovarname}" TI_INSPECTED_VALUE)
    set(${ovarname} "${TI_INSPECTED_VALUE}" PARENT_SCOPE)
  endforeach()
endfunction()
