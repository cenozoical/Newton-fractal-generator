
#

cmake_minimum_required(VERSION 4.0)
set(CMAKE_ISPC_COMPILER "/snap/bin/ispc")
project(Newton_fractal_generator LANGUAGES CXX ISPC)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_ISPC_INSTRUCTION_SETS "avx2")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

add_library(ispc_lib STATIC vectorized_functions.ispc)

target_include_directories(ispc_lib PUBLIC $<TARGET_PROPERTY:ispc_lib,ISPC_HEADER_DIRECTORY>)

# Add your main C++ executable
add_executable(Newton_fractal_generator main.cpp)

# Link the executable with the ISPC library
target_link_libraries(Newton_fractal_generator PRIVATE ispc_lib)

target_include_directories(Newton_fractal_generator PRIVATE $<TARGET_PROPERTY:ispc_lib,INTERFACE_INCLUDE_DIRECTORIES>)