cmake_minimum_required(VERSION 2.8.9)

project (bugprone)
add_executable(bugprone src/file-with-bugprone.cpp)
project (not-bugprone-1)
add_executable(not-bugprone-1 src/file-without-bugprone-1.cpp)
project (not-bugprone-2)
add_executable(not-bugprone-2 src/file-without-bugprone-2.cpp)
