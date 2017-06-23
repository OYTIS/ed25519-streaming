cmake_minimum_required (VERSION 2.6)

project(ed25519-streaming)

option(WARNING_AS_ERROR "Treat warnings as errors" ON)

# clang-check and clang-format
# The .clang-format file requires clang-format-3.8
find_program(CLANG_FORMAT NAMES clang-format clang-format-3.8)
find_program(CLANG_CHECK NAMES clang-check clang-check-3.8 clang-check-3.7 clang-check-3.6 clang-check-3.5 clang-check-3.4)


if(NOT CMAKE_BUILD_TYPE)
    message(STATUS "No CMAKE_BUILD_TYPE specified, defaulting to Debug")
    set(CMAKE_BUILD_TYPE Debug)
endif(NOT CMAKE_BUILD_TYPE)

set(CMAKE_C_FLAGS_DEBUG "-g -Os")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(COMMON_SOURCES
            src/common/ed25519.c
            src/common/f25519.c
            src/common/fprime.c
            src/common/sha512.c)

set(COMMON_HEADERS
            src/common/ed25519.h
            src/common/f25519.h
            src/common/fprime.h
            src/common/sha512.h)

set(REFERENCE_SOURCES
            src/reference/edsign.c)

set(REFERENCE_HEADERS
            src/reference/edsign.h)

set(STREAMING_SOURCES
            src/streaming/edsign.c)

set(STREAMING_HEADERS
            src/streaming/edsign.h)


include_directories(src/common)

set(ALL_SOURCES ${COMMON_SOURCES} ${REFERENCE_SOURCES} ${STREAMING_SOURCES} src/genpair.c src/sign.c src/verify_reference.c src/verify_streaming.c)
set(ALL_HEADERS ${COMMON_HEADERS} ${REFERENCE_HEADERS} ${STREAMING_HEADERS})

add_executable(genpair ${COMMON_SOURCES} ${REFERENCE_SOURCES} src/genpair.c)
target_include_directories(genpair PUBLIC src/reference)

add_executable(sign_reference ${COMMON_SOURCES} ${REFERENCE_SOURCES} src/sign.c)
target_include_directories(sign_reference PUBLIC src/reference)

add_executable(sign_streaming ${COMMON_SOURCES} ${STREAMING_SOURCES} src/sign.c)
target_include_directories(sign_streaming PUBLIC src/streaming)

add_executable(verify_reference ${COMMON_SOURCES} ${REFERENCE_SOURCES} src/verify_reference.c)
target_include_directories(verify_reference PUBLIC src/reference)

add_executable(verify_streaming ${COMMON_SOURCES} ${STREAMING_SOURCES} src/verify_streaming.c)
target_include_directories(verify_streaming PUBLIC src/streaming)


# Tests
enable_testing()

set(test_exec ${CMAKE_CURRENT_SOURCE_DIR}/test/test_ed.sh)
add_test(NAME test_signatures_match COMMAND ${test_exec} sign 1000)
add_test(NAME test_signatures_match_tiny COMMAND ${test_exec} sign 10)
add_test(NAME test_signatures_match_small COMMAND ${test_exec} sign 150)
add_test(NAME test_signatures_match_aligned COMMAND ${test_exec} sign 512)

add_test(NAME test_verify_reference COMMAND ${test_exec} verify-reference 1000)
add_test(NAME test_verify_reference_tiny COMMAND ${test_exec} verify-reference 10)
add_test(NAME test_verify_reference_small COMMAND ${test_exec} verify-reference 150)
add_test(NAME test_verify_reference_aligned COMMAND ${test_exec} verify-reference 512)

add_test(NAME test_verify_streaming COMMAND ${test_exec} verify-streaming 1000)
add_test(NAME test_verify_streaming_tiny COMMAND ${test_exec} verify-streaming 10)
add_test(NAME test_verify_streaming_small COMMAND ${test_exec} verify-streaming 150)
add_test(NAME test_verify_streaming_aligned COMMAND ${test_exec} verify-streaming 512)

add_custom_target(qa)
if(CLANG_FORMAT)
    add_custom_target(format-src
        COMMAND ${CLANG_FORMAT} -i -style=file ${ALL_SOURCES} ${ALL_HEADERS}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running clang-format on src"
        VERBATIM)
    add_dependencies(qa format-src)
else()
    message(WARNING "clang-format not found, skipping")
endif()

if(CLANG_CHECK)
    add_custom_target(check-src
        COMMAND ${CLANG_CHECK} -analyze -p ${CMAKE_BINARY_DIR} ${ALL_SOURCES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running clang-check"
        VERBATIM)
    add_dependencies(qa check-src)
else()
    message(WARNING "clang-check not found, skipping")
endif(CLANG_CHECK)

# Generate ctags
set_source_files_properties(tags PROPERTIES GENERATED true)
add_custom_target(tags
    COMMAND ctags -R --c++-kinds=+p --fields=+iaS --extra=+q src
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

# vim: set tabstop=4 shiftwidth=4 expandtab:
