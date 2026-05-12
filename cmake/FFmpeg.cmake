# Подключает FFmpeg как INTERFACE-таргет 'ffmpeg'.
# На Linux/macOS используется pkg-config (системные пакеты из apt/brew).
# На Windows ожидается vcpkg toolchain — vcpkg ставит и .pc файлы, и FFMPEGConfig.cmake.

find_package(PkgConfig REQUIRED)
pkg_check_modules(FFMPEG REQUIRED IMPORTED_TARGET
    libavcodec
    libavformat
    libavutil
    libavfilter
    libswscale
    libswresample
)

add_library(ffmpeg INTERFACE)
target_link_libraries(ffmpeg INTERFACE PkgConfig::FFMPEG)

message(STATUS "FFmpeg via pkg-config: libavcodec ${FFMPEG_libavcodec_VERSION}")
