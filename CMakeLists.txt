cmake_minimum_required(VERSION 3.10)
project(search_algorithms)

set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

find_package(SDL3 REQUIRED)
find_package(SDL3_ttf REQUIRED)

add_executable(${PROJECT_NAME}
  src/main.c
  src/graph.c
  src/algorithms.c
)

target_link_libraries(${PROJECT_NAME} SDL3::SDL3 SDL3_ttf::SDL3_ttf)

