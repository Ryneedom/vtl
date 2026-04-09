# FFmpeg.cmake — minimal-working branch
#
# Использует системный FFmpeg через pkg-config вместо сборки из external/ffmpeg.
# Зачем: сборка FFmpeg из исходников (ExternalProject_Add) в минимальной рабочей
# ветке не нужна и ломает сборку в WSL/Linux. Системный FFmpeg ставится через apt:
#   sudo apt install -y libavcodec-dev libavformat-dev libavfilter-dev libswscale-dev libavutil-dev
#
# Создаёт INTERFACE-таргет 'ffmpeg', который ожидает корневой CMakeLists.txt.

find_package(PkgConfig REQUIRED)

pkg_check_modules(FFMPEG_SYS REQUIRED IMPORTED_TARGET
    libavcodec
    libavformat
    libavfilter
    libavutil
    libswscale
    libswresample
)

add_library(ffmpeg INTERFACE)
target_link_libraries(ffmpeg INTERFACE PkgConfig::FFMPEG_SYS)

message(STATUS "FFmpeg: using system libraries via pkg-config (libavcodec )")
