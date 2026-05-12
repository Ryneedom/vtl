# Создаем библиотеку для обработки изображений
add_library(VTL_img STATIC
    VTL_img_core.c
    VTL_img_filters.c
    VTL_img_utils.c
)

# Заголовочные файлы
target_include_directories(VTL_img PUBLIC ${CMAKE_SOURCE_DIR})

# Линкуем с FFmpeg (таргет из cmake/FFmpeg.cmake)
target_link_libraries(VTL_img PRIVATE ffmpeg)

# Флаги компиляции
if(MSVC)
    target_compile_options(VTL_img PRIVATE /W4 /utf-8)
else()
    target_compile_options(VTL_img PRIVATE
        -Wall -Wextra -Werror -Wno-unused-parameter
        -Wno-error=implicit-function-declaration
        -Wno-error=incompatible-pointer-types
        -Wno-error=int-conversion
    )
endif()

target_compile_definitions(VTL_img PRIVATE VTL_IMG_EXPORTS)

if(NOT WIN32)
    target_compile_definitions(VTL_img PRIVATE _GNU_SOURCE)
endif()

set_target_properties(VTL_img PROPERTIES
    C_STANDARD 11
    C_STANDARD_REQUIRED ON
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)
