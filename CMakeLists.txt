cmake_minimum_required(VERSION 3.20)

project(VTL LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

set(AppName ${CMAKE_PROJECT_NAME})

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/app)

# Поиск системных зависимостей.
# Linux:   apt install libavcodec-dev libavformat-dev libavutil-dev libavfilter-dev
#                       libswscale-dev libswresample-dev libcurl4-openssl-dev libssl-dev libpq-dev
# macOS:   brew install ffmpeg curl openssl postgresql pkg-config
# Windows: vcpkg install ffmpeg curl openssl libpq + toolchain через -DCMAKE_TOOLCHAIN_FILE=...\vcpkg.cmake
find_package(CURL REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(PostgreSQL REQUIRED)

include(cmake/FFmpeg.cmake)

add_subdirectory(external_sources/parson)

add_subdirectory(VTL/utils)
add_subdirectory(VTL/user)
add_subdirectory(VTL/publication)
add_subdirectory(VTL/media_container)
add_subdirectory(VTL/content_platform)

add_executable(${AppName} main.c)

target_link_libraries(${AppName} PRIVATE
    VTL_content_platform
    VTL_publication
    VTL_media_container
    VTL_user
    VTL_utils
)

if(UNIX)
    target_link_libraries(${AppName} PRIVATE pthread dl)
endif()

enable_testing()
