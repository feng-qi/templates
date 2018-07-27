# Global setup
cmake_minimum_required(VERSION 3.5)

if(MSVC)
  add_compile_options(/W3 /WX)
else()
  add_compile_options(-W -Wall -Werror)
endif()


# Declare your module
add_library(mylib
  src/file1.cpp
  src/file2.cpp)


# Declare your flags
target_include_directories(mylib PUBLIC include)
target_include_directories(mylib PRIVATE include)

target_compile_options(mylib -Wextra -Wconversion)

if (SOME_PUBLIC_SETTING)
  target_compile_definitions(mylib
    PUBLIC WITH_SOME_PUBLIC_SETTING)
endif()

if (SOME_PRIVATE_SETTING)
  target_compile_definitions(mylib
    PRIVATE WITH_SOME_PRIVATE_SETTING)
endif()


# Declare your dependencies
# Public (interface) dependencies
target_link_libraries(mylib PUBLIC abc)

# Private (implementation) dependencies
target_link_libraries(mylib PRIVATE xyz)


# Header-only libraries
# nothing to build so it must be `INTERFACE'
add_library(mylib INTERFACE)

target_include_directories(mylib INTERFACE include)

target_link_libraries(mylib INTERFACE Boost::Boost)


# External projects
find_package(GTest)
find_package(Threads)

add_executable(foo foo.cc)

target_include_directories(foo
  PRIVATE ${GTEST_INCLUDE_DIRS})

target_link_libraries(foo
  GTest::GTest GTest::Main)
target_link_libraries(foo
  PRIVATE ${GTEST_BOTH_LIBRARIES}
          Threads::Threads)

# Finder reality
find_library(BAR_LIB bar HINTS ${BAR_DIR}/lib)
add_library(bar SHARED IMPORTED)
set_target_properties(bar PROPERTIES
  LOCATION ${BAR_LIB})
set_target_properties(bar PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${BAR_DIR}/include
  INTERFACE_LINK_LIBRARIES Boost::Boost)
