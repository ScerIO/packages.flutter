cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "pdfx")
project(${PROJECT_NAME} LANGUAGES CXX)

set(ARCH "x64")
set(PDFIUM_VERSION "4634" CACHE STRING "Version of pdfium used")

string(COMPARE GREATER_EQUAL ${PDFIUM_VERSION} "4690" PDFIUM_BINARY_NEW_FORMAT)

if(${PDFIUM_VERSION} STREQUAL "latest")
  set(PDFIUM_URL "https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-windows-${ARCH}.zip")
elseif(PDFIUM_BINARY_NEW_FORMAT)
  set(PDFIUM_URL "https://github.com/bblanchon/pdfium-binaries/releases/download/chromium/${PDFIUM_VERSION}/pdfium-win-${ARCH}.tgz")
else()
  set(PDFIUM_URL "https://github.com/bblanchon/pdfium-binaries/releases/download/chromium/${PDFIUM_VERSION}/pdfium-windows-${ARCH}.zip")
endif()

# Download pdfium
include(../windows/DownloadProject.cmake)
download_project(
  PROJ
  pdfium
  URL
  ${PDFIUM_URL}
  DOWNLOAD_EXTRACT_TIMESTAMP
  FALSE
)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "pdfx_plugin")

include(${pdfium_SOURCE_DIR}/PDFiumConfig.cmake)

add_library(${PLUGIN_NAME} SHARED
  "pdfx.cpp"
  "pdfx.h"
  "pdfx_plugin.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE pdfium flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(pdfx_bundled_libraries
  "${PDFium_LIBRARY}"
  PARENT_SCOPE
)
