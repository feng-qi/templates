cmake_minimum_required(VERSION 3.8)
project(Calculator)

#-------- SETUP: variables --------------
# set(BOOST_INCLUDE_DIR /usr/include/boost)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)   # default ON

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


#-------- SETUP: compiler flags --------------
# The DEFAULT(EMPTY) flags will not be inherited by {DEBUG,RELEASE} flags
# Use different flags according to ${CMAKE_BUILD_TYPE}
set(CMAKE_C_FLAGS         "${CMAKE_C_FLAGS} -Wall -Werror")
set(CMAKE_C_FLAGS_DEBUG   "${CMAKE_C_FLAGS_DEBUG} -O0 -Wall -Werror")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -Wall -Werror")
set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -Wall -Werror")
set(CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS_DEBUG} -O0 -Wall -Werror")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -Wall -Werror")


#-------- SETUP: linker flags --------------
# set(LINKER_FLAGS "-v")
# set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LINKER_FLAGS}")


#-------- SETUP: output directories --------------
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib) # static libraries
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib) # shared libraries
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin) # executables


#-------- SETUP: enable testing --------------
enable_testing()


#-------- SETUP: run programs --------------
#-- at configure time --
execute_process(COMMAND thrift ${THRIFT_ARGS})
# file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/thirft)

#-- at build time --
add_custom_command(
  OUTPUT  "${CMAKE_CURRENT_BINARY_DIR}/gen-cpp/ThriftRPC.cpp"
  COMMAND echo "running thrift..."
  COMMAND thrift -r -strict --gen cpp -o ${THRIFT_GEN_DIR} ${THRIFT_FILE}
  DEPENDS ${THRIFT_FILE})

# If the OUTPUT of add_custom_command is not dependent by any target, it won't
# run. So we add a custom_target.
add_custom_target(
  generate_header
  ALL
  DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/gen-cpp/ThriftRPC.cpp")


#-------- SETUP: function --------------
function(complex)
  cmake_parse_arguments(
    COMPLEX_PREFIX
    "OPTION1;OPTION2"
    "ONE_VALUE;ALSO_ONE_VALUE"
    "MULTI_VALUES"
    ${ARGN}
    )
  message("COMPLEX_PREFIX_OPTION1:        ${COMPLEX_PREFIX_OPTION1}")
  message("COMPLEX_PREFIX_OPTION2:        ${COMPLEX_PREFIX_OPTION2}")
  message("COMPLEX_PREFIX_ONE_VALUE:      ${COMPLEX_PREFIX_ONE_VALUE}")
  message("COMPLEX_PREFIX_ALSO_ONE_VALUE: ${COMPLEX_PREFIX_ALSO_ONE_VALUE}")
  message("COMPLEX_PREFIX_MULTI_VALUES:   ${COMPLEX_PREFIX_MULTI_VALUES}")
  # message("ARGV: ${ARGV}\nARGN: ${ARGN}")
endfunction()

complex(
  OPTION1
  OPTION2
  ONE_VALUE      value
  ALSO_ONE_VALUE value2
  MULTI_VALUES   some other values hello)


#-------- SETUP: executable --------------
add_executable(server
  server.cpp
  ${THRIFT_GENED_SRCS}
  )


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
