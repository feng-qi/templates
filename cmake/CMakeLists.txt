cmake_minimum_required(VERSION 3.0)
project(Calculator)

#-------- SETUP: variables --------------
# set(BOOST_INCLUDE_DIR /usr/include/boost)
set(THRIFT_INCLUDE_DIR
  /usr/local/include/thrift)
set(THRIFT_GENED_DIR
  ${CMAKE_BINARY_DIR}/gen-cpp)
set(THRIFT_GENED_SRCS
  ${THRIFT_GENED_DIR}/calculator_types.cpp
  ${THRIFT_GENED_DIR}/Calculator.cpp
  ${THRIFT_GENED_DIR}/calculator_constants.cpp
  )
set(THRIFT_ARGS --gen cpp ${CMAKE_SOURCE_DIR}/thrift/calculator.thrift)


#-------- SETUP: shell commands --------------
execute_process(COMMAND thrift ${THRIFT_ARGS})
# file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/thirft)


#-------- SETUP: executable --------------
add_executable(server
  server.cpp
  ${THRIFT_GENED_SRCS}
  )


#-------- SETUP: linker flags --------------
# set(LINKER_FLAGS "-v")
# set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LINKER_FLAGS}")


#-------- SETUP: includes --------------
target_include_directories(server
  PRIVATE ${THRIFT_GENED_DIR}
  ${THRIFT_INCLUDE_DIR}
  # ${BOOST_INCLUDE_DIR}
  )


#-------- SETUP: libraries --------------
find_library(LIB_THRIFT
  NAMES libthrift.a libthriftnb.a
  PATHS /usr/local/lib)
find_library(LIB_PTHREAD
  NAMES pthread)
target_link_libraries(server ${LIB_THRIFT} ${LIB_PTHREAD})
