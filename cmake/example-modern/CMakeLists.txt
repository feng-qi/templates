cmake_minimum_required(VERSION 3.5)

add_compile_options(-Wall -Werror)

find_package(GTest)
find_package(Threads)

add_executable(main
  main.cc)

target_include_directories(main
  PRIVATE
  ${CMAKE_SOURCE_DIR}
  ${GTEST_INCLUDE_DIRS})

enable_testing()

add_executable(add_test
  add_test.cc)

target_include_directories(add_test
  PRIVATE ${CMAKE_SOURCE_DIR})

target_link_libraries(add_test
  GTest::GTest
  GTest::Main)

target_link_libraries(add_test
  Threads::Threads)

add_test(
  NAME
  add_test
  COMMAND
  ./add_test)
