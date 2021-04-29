cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "native_pdf_renderer")
project(${PROJECT_NAME} LANGUAGES CXX)

set(ARCH "x64")

# Download pdfium
include(../windows/DownloadProject.cmake)
download_project(
  PROJ
  pdfium
  URL
  https://github.com/bblanchon/pdfium-binaries/releases/download/chromium%2F4475/pdfium-windows-x64.zip
  )

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "native_pdf_renderer_plugin")

include(${pdfium_SOURCE_DIR}/PDFiumConfig.cmake)

add_library(${PLUGIN_NAME} SHARED
  "native_pdf_renderer.cpp"
  "native_pdf_renderer.h"
  "native_pdf_renderer_plugin.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE pdfium flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(native_pdf_renderer_bundled_libraries
  "${PDFium_LIBRARY}"
  PARENT_SCOPE
)
