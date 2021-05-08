cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(TargetInspector)

# target_inspect can be used before project() or any enable_language(C CXX)
# call
# it will not interfere with this cmake configuration flow as it uses its
# own dummy project to inspect the variables
target_inspect(
  INSPECT_VARIABLE
    CMAKE_SYSTEM_NAME
    CMAKE_SYSTEM_PROCESSOR
    CMAKE_C_COMPILER
    CMAKE_CXX_COMPILER
  OUTPUT_VARNAME
    INSPECTED_SYSTEM_NAME
    INSPECTED_SYSTEM_PROCESSOR
    INSPECTED_C_COMPILER
    INSPECTED_CXX_COMPILER
 )

project(TargetInspectorDemo
  LANGUAGES
    C CXX
)

message("

Once the project enabled the c/c++ languages:
  CMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME}
  CMAKE_SYSTEM_PROCESSOR=${CMAKE_SYSTEM_PROCESSOR}
  CMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}

Here is what TargetInspector could inspect:
  INSPECTED_SYSTEM_NAME=${INSPECTED_SYSTEM_NAME}
  INSPECTED_SYSTEM_PROCESSOR=${INSPECTED_SYSTEM_PROCESSOR}
  INSPECTED_C_COMPILER=${INSPECTED_C_COMPILER}
  INSPECTED_CXX_COMPILER=${INSPECTED_CXX_COMPILER}


"
)
