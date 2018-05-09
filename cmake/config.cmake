function(detect_header_file file macro)
  unset(exists CACHE)
  check_include_files("${file}" exists)
  if (exists)
    add_definitions("-D${macro}")
    unset(exists CACHE)
  endif (exists)
endfunction(detect_header_file)

function(detect_function func macro)
  unset(exists CACHE)
  check_function_exists("${func}" exists)
  if (exists)
    add_definitions("-D${macro}")
    unset(exists CACHE)
  endif (exists)
endfunction(detect_function)

function(detect_cxx_feature feature macro)
  cmake_policy(SET CMP0057 NEW)
  if ("${feature}" IN_LIST CMAKE_CXX_COMPILE_FEATURES)
    add_definitions("-D${macro}")
  endif ()
endfunction(detect_cxx_feature)

function(detect_optional om eom)
  unset(exists CACHE)
  check_cxx_source_compiles("
    #include <optional>
    int main() { std::optional<int> o; }
  " exists)
  if (exists)
    add_definitions("-D${om}")
    unset(exists CACHE)
  else (exists)
    check_cxx_source_compiles("
      #include <experimental/optional>
      int main() { std::experimental::optional<int> o; }
    " exists)
    if (exists)
      add_definitions("-D${eom}")
      unset(exists CACHE)
    endif (exists)
  endif (exists)
endfunction(detect_optional)

include(CheckIncludeFiles)
include(CheckFunctionExists)
include(CMakeDetermineCompileFeatures)
include(CheckCXXSourceCompiles)

detect_header_file("dlfcn.h" HAVE_DLFCN_H)
detect_header_file("inttypes.h" HAVE_INTTYPES_H)
detect_header_file("memory.h" HAVE_MEMORY_H)
detect_header_file("stdint.h" HAVE_STDINT_H)
detect_header_file("stdlib.h" HAVE_STDLIB_H)
detect_header_file("strings.h" HAVE_STRINGS_H)
detect_header_file("string.h" HAVE_STRING_H)
detect_header_file("sys/select.h" HAVE_SYS_SELECT_H)
detect_header_file("sys/stat.h" HAVE_SYS_STAT_H)
detect_header_file("sys/time.h" HAVE_SYS_TIME_H)
detect_header_file("sys/types.h" HAVE_SYS_TYPES_H)
detect_header_file("unistd.h" HAVE_UNISTD_H)

detect_function("poll" HAVE_POLL)

cmake_determine_compile_features(CXX)
detect_cxx_feature("cxx_attribute_deprecated" "PQXX_HAVE_DEPRECATED")

# check_cxx_source_compiles requires CMAKE_REQUIRED_DEFINITIONS to specify compiling arguments
# Wordaround: Push CMAKE_REQUIRED_DEFINITIONS
if (CMAKE_REQUIRED_DEFINITIONS)
  set(def "${CMAKE_REQUIRED_DEFINITIONS}")
endif (CMAKE_REQUIRED_DEFINITIONS)
set(CMAKE_REQUIRED_DEFINITIONS ${CMAKE_CXX17_STANDARD_COMPILE_OPTION})

detect_optional(PQXX_HAVE_OPTIONAL PQXX_HAVE_EXP_OPTIONAL)

# check_cxx_source_compiles requires CMAKE_REQUIRED_DEFINITIONS to specify compiling arguments
# Wordaround: Pop CMAKE_REQUIRED_DEFINITIONS
if (def)
  set(CMAKE_REQUIRED_DEFINITIONS ${def})
  unset(def CACHE)
else (def)
  unset(CMAKE_REQUIRED_DEFINITIONS CACHE)
endif (def)
