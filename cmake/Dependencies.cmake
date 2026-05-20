# Подключает зависимости из external_libs/ как IMPORTED CMake-таргеты.
# Никаких find_package / pkg-config — всё локально в репо.
# Цель: проект собирается на чистой ОС без apt/brew/vcpkg.
#
# Поддерживаемые платформы:
#   Linux x86_64      → external_libs/{curl,postgresql}/lib/*.so
#   Windows x86_64    → собирается из external_sources/ под MSVC
#   macOS arm64       → external_libs/macos/lib/*.dylib

set(EXTERNAL_LIBS_DIR "${CMAKE_SOURCE_DIR}/external_libs")

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    include("${CMAKE_CURRENT_LIST_DIR}/Dependencies-Windows.cmake")
    return()
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    include("${CMAKE_CURRENT_LIST_DIR}/Dependencies-MacOS.cmake")
    return()
endif()

if(NOT (CMAKE_SYSTEM_NAME STREQUAL "Linux"))
    message(FATAL_ERROR
        "external_libs/ под ${CMAKE_SYSTEM_NAME} пока нет. "
        "Поддерживается Linux x86_64, Windows x86_64 (MSVC), macOS arm64.")
endif()

# Создаём недостающие файлы .so.MAJOR — физической копией .so.MAJOR.MINOR.PATCH.
# Они нужны для runtime: линкер записывает в DT_NEEDED soname библиотеки,
# а в репо изначально лежит только версионированный файл.
function(_vtl_ensure_soname dir versioned soname_name)
    set(target "${dir}/${soname_name}")
    if(NOT EXISTS "${target}")
        configure_file("${dir}/${versioned}" "${target}" COPYONLY)
    endif()
endfunction()

# ============================================================
# FFmpeg — заглушка (см. комментарий ниже)
# ============================================================
# Бандленный external_libs/ffmpeg/lib/libavcodec.so.60 собран с 40+ опциональными
# кодеками (libvpx, libdav1d, libaom, libopus, libmp3lame, libwebp, libx264, ...),
# которые прописаны в его DT_NEEDED. На пустой Linux-системе их нет → ld.so при
# старте бинаря падает с "libvpx.so.9: cannot open shared object file".
#
# Чтобы не блокировать сборку, FFmpeg-таргет сделан ПУСТОЙ INTERFACE-библиотекой:
# заголовки доступны для компиляции, но никакая .so не подтягивается в DT_NEEDED.
# Все FFmpeg-вызовы в нашем коде линкуются как unresolved (см. ignore-all ниже)
# и при runtime-вызове просто сегфолтятся. Текстовые пайплайны (MediaWiki,
# AsciiDoc) их не зовут → работают штатно. Видео-пайплайн временно нерабочий.
#
# TODO: вернуть рабочий FFmpeg — либо static build из external_sources/ffmpeg/
# (требует pkg-config/yasm и аккуратной настройки), либо бандлить недостающие
# transient .so вместе с libavcodec, либо использовать ОС-системный ffmpeg.
add_library(ffmpeg INTERFACE)
target_include_directories(ffmpeg INTERFACE
    "${EXTERNAL_LIBS_DIR}/ffmpeg/include"
)

# ============================================================
# libcurl
# ============================================================
set(CURL_LIB_DIR "${EXTERNAL_LIBS_DIR}/curl/lib")
set(CURL_INC_DIR "${EXTERNAL_LIBS_DIR}/curl/include")

_vtl_ensure_soname("${CURL_LIB_DIR}" "libcurl.so.4.8.0" "libcurl.so.4")

add_library(CURL::libcurl SHARED IMPORTED)
set_target_properties(CURL::libcurl PROPERTIES
    IMPORTED_LOCATION "${CURL_LIB_DIR}/libcurl.so.4.8.0"
    INTERFACE_INCLUDE_DIRECTORIES "${CURL_INC_DIR}"
)

# ============================================================
# libpq (PostgreSQL)
# ============================================================
set(PG_LIB_DIR "${EXTERNAL_LIBS_DIR}/postgresql/lib")
set(PG_INC_DIR "${EXTERNAL_LIBS_DIR}/postgresql/include")

_vtl_ensure_soname("${PG_LIB_DIR}" "libpq.so.5.16" "libpq.so.5")

add_library(PostgreSQL::PostgreSQL SHARED IMPORTED)
set_target_properties(PostgreSQL::PostgreSQL PROPERTIES
    IMPORTED_LOCATION "${PG_LIB_DIR}/libpq.so.5.16"
    INTERFACE_INCLUDE_DIRECTORIES "${PG_INC_DIR}"
)

# ============================================================
# Линкер: разрешить ВСЕ неразрешённые символы
# ============================================================
# FFmpeg-таргет пустой (см. выше) — все вызовы avcodec_* / avformat_* / sws_* /
# av_* становятся unresolved на этапе линковки. Флаг ignore-all это разрешает.
# Это шире, чем ignore-in-shared-libs: позволяет линковать бинарь даже когда
# нет ни одной библиотеки, реализующей символ.
# На runtime вызов unresolved-функции → SIGSEGV. Это осознанный trade-off:
# Текстовые пайплайны работают, видео — нет (см. TODO выше).
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    add_link_options(-Wl,--unresolved-symbols=ignore-all)
endif()

# ============================================================
# RPATH
# ============================================================
# Бинарь app/VTL должен находить .so в external_libs/<pkg>/lib/ во время запуска.
# Используем $ORIGIN — относительный путь от бинаря.
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
set(CMAKE_INSTALL_RPATH
    "\$ORIGIN/../external_libs/curl/lib"
    "\$ORIGIN/../external_libs/postgresql/lib"
)

message(STATUS "VTL dependencies: curl 4, libpq 5 (FFmpeg — заглушка, видео временно нерабочее)")
