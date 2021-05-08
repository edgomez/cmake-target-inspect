# CMake helper module

## Description

One may want to inspect a few variables before any call to
`enable_language(C|CXX)` or `project(FOO LANGUAGES C CXX)`
is done in a project's CMakeLists.txt

For example some VSI plugins for VisualStudio mandate certain
configuration names. Detecting the platform to set
`CMAKE_CONFIGURATION_TYPES` becomes a hard problem.
How one can retrieve these information before the C/CXX languages
are enabled or `project()` is called. Only at that time,
`CMAKE_SYSTEM_NAME` and `CMAKE_SYSTEM_PROCESSOR` are fully
determined. But `CMAKE_CONFIGURATION_TYPES` are kind of frozen
internally by CMake.

Come to the rescue TargetInspector. It allows one to inspect
the variables values from a dummy project configured as closely
as possible to the current project. The inspected values are
imported back in the current scope, and evrything is done
in parallel to the currently configured cmake project so
its context is left untainted by a premature reading of the
toolchain file or any language activation...

## How to use

    list(APPEND CMAKE_MODULE_PATH "${WHERE_TARGETINSPECTOR_IS_DIR}")
    include(TargetInspect)
    target_inspect(INSPECT_VARIABLE FOO BAR OUTPUT_VARNAME INSPECTED_FOO INSPECTED_BAR)
    message("inspected FOO = ${INSPECTED_FOO}")
    message("inspected BAR = ${INSPECTED_BAR}")

Read the top directory `CMakeLists.txt` for an example.

# LICENSE

Copyright 2021 Edouard Gomez
Licensed under the terms of the MIT License

Read the file LICENSE for the complete legal text
