add_library(parson STATIC parson.c)

target_include_directories(parson PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/..)

set_target_properties(parson PROPERTIES
    C_STANDARD 11
    C_STANDARD_REQUIRED ON
)
