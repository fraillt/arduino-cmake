#=============================================================================#
# ToDo: Document
#=============================================================================#
set(PLATFORM_PATH ${ARDUINO_SDK_PATH}/hardware/arduino/)
string(REGEX REPLACE "/$" "" PLATFORM_PATH ${PLATFORM_PATH})
GET_FILENAME_COMPONENT(PLATFORM ${PLATFORM_PATH} NAME)

# platform path changed in versions 1.5 and greater
if (ARDUINO_SDK_VERSION VERSION_GREATER 1.0.5)
    set(PLATFORM_PATH "${PLATFORM_PATH}/avr")
endif ()

if (NOT PLATFORM)
    return()
endif ()

# Avoid defining a platform multiple times if it has already been defined before
string(TOUPPER ${PLATFORM} PLATFORM)
list(FIND ARDUINO_PLATFORMS ${PLATFORM} PLATFORM_EXISTS)

if (PLATFORM_EXISTS GREATER -1)
    return()
endif ()

set(${PLATFORM}_PLATFORM_PATH ${PLATFORM_PATH} CACHE INTERNAL "The path to ${PLATFORM}")
set(ARDUINO_PLATFORMS ${ARDUINO_PLATFORMS} ${PLATFORM} CACHE INTERNAL "A list of registered platforms")

find_file(${PLATFORM}_CORES_PATH
        NAMES cores
        PATHS ${PLATFORM_PATH}
        DOC "Path to directory containing the Arduino core sources.")

find_file(${PLATFORM}_VARIANTS_PATH
        NAMES variants
        PATHS ${PLATFORM_PATH}
        DOC "Path to directory containing the Arduino variant sources.")

find_file(${PLATFORM}_BOOTLOADERS_PATH
        NAMES bootloaders
        PATHS ${PLATFORM_PATH}
        DOC "Path to directory containing the Arduino bootloader images and sources.")

find_file(${PLATFORM}_PROGRAMMERS_PATH
        NAMES programmers.txt
        PATHS ${PLATFORM_PATH}
        DOC "Path to Arduino programmers definition file.")

find_file(${PLATFORM}_BOARDS_PATH
        NAMES boards.txt
        PATHS ${PLATFORM_PATH}
        DOC "Path to Arduino boards definition file.")

# some libraries are in platform path in versions 1.5 and greater
if (ARDUINO_SDK_VERSION VERSION_GREATER 1.0.5)
    find_file(${PLATFORM}_PLATFORM_LIBRARIES_PATH
            NAMES libraries
            PATHS ${PLATFORM_PATH}
            DOC "Path to platform directory containing the Arduino libraries.")
    set(ARDUINO_PLATFORM_LIBRARIES_PATH "${${PLATFORM}_PLATFORM_LIBRARIES_PATH}")
else ()
    set(ARDUINO_PLATFORM_LIBRARIES_PATH "")
endif ()

if (${PLATFORM}_BOARDS_PATH)
    load_arduino_style_settings(${PLATFORM}_BOARDS "${PLATFORM_PATH}/boards.txt")
endif ()

if (${PLATFORM}_PROGRAMMERS_PATH)
    load_arduino_style_settings(${PLATFORM}_PROGRAMMERS "${ARDUINO_PROGRAMMERS_PATH}")
endif ()

if (${PLATFORM}_VARIANTS_PATH)
    file(GLOB sub-dir ${${PLATFORM}_VARIANTS_PATH}/*)
    foreach (dir ${sub-dir})
        if (IS_DIRECTORY ${dir})
            get_filename_component(variant ${dir} NAME)
            set(VARIANTS ${VARIANTS} ${variant} CACHE INTERNAL "A list of registered variant boards")
            set(${variant}.path ${dir} CACHE INTERNAL "The path to the variant ${variant}")
        endif ()
    endforeach ()
endif ()

if (${PLATFORM}_CORES_PATH)
    file(GLOB sub-dir ${${PLATFORM}_CORES_PATH}/*)
    foreach (dir ${sub-dir})
        if (IS_DIRECTORY ${dir})
            get_filename_component(core ${dir} NAME)
            set(CORES ${CORES} ${core} CACHE INTERNAL "A list of registered cores")
            set(${core}.path ${dir} CACHE INTERNAL "The path to the core ${core}")
        endif ()
    endforeach ()
endif ()