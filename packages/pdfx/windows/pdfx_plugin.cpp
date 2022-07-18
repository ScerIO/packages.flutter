#include "include/pdfx/pdfx_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// Flutter imports
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

// std imports
#include <iostream>
#include <map>
#include <memory>
#include <sstream>
#include <stdexcept>

// Library linking
#include <pathcch.h>
#pragma comment(lib, "pathcch.lib")

#include <shlwapi.h>
#pragma comment(lib, "shlwapi.lib")

#include "pdfx.h"

namespace pdfx {

// Convert a wide Unicode string to an UTF8 string
std::string utf8_encode(const std::wstring& wstr) {
  if (wstr.empty()) return std::string();
  int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(),
                                        NULL, 0, NULL, NULL);
  std::string strTo(size_needed, 0);
  WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), &strTo[0],
                      size_needed, NULL, NULL);
  return strTo;
}

const char kOpenDocumentDataMethod[] = "open.document.data";
const char kOpenDocumentFileMethod[] = "open.document.file";
const char kOpenDocumentAssetMethod[] = "open.document.asset";
const char kOpenPageMethod[] = "open.page";
const char kCloseDocumentMethod[] = "close.document";
const char kClosePageMethod[] = "close.page";
const char kRenderMethod[] = "render";

class PdfxPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  PdfxPlugin();

  virtual ~PdfxPlugin();

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void PdfxPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "io.scer.pdf_renderer",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<PdfxPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

PdfxPlugin::PdfxPlugin() {}

PdfxPlugin::~PdfxPlugin() {}

void PdfxPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  ///
  /// Open document from flutter asset
  ///
  if (method_call.method_name().compare(kOpenDocumentAssetMethod) == 0) {
    auto name = std::get<std::string>(*method_call.arguments());

    // Get .exe base path
    WCHAR basePath[MAX_PATH];
    GetModuleFileNameW(NULL, basePath, MAX_PATH);
#if (NTDDI_VERSION >= NTDDI_WIN8)
    PathCchRemoveFileSpec(basePath, MAX_PATH);
#else
    PathRemoveFileSpec(basePath);
#endif

    // Construct new path
    std::string path =
        utf8_encode(basePath) + "\\data\\flutter_assets\\" + name;

    try {
      std::shared_ptr<Document> doc = openDocument(path);

      auto mp = flutter::EncodableMap{};
      mp[flutter::EncodableValue("id")] = flutter::EncodableValue(doc->id);
      mp[flutter::EncodableValue("pagesCount")] =
          flutter::EncodableValue(doc->getPageCount());
      result->Success(mp);
    } catch (std::exception& e) {
      result->Error("pdfx_exception", e.what());
    }
  }

  ///
  /// Open document from file
  ///
  else if (method_call.method_name().compare(kOpenDocumentFileMethod) == 0) {
    auto name = std::get<std::string>(*method_call.arguments());

    try {
      std::shared_ptr<Document> doc = openDocument(name);

      auto mp = flutter::EncodableMap{};
      mp[flutter::EncodableValue("id")] = flutter::EncodableValue(doc->id);
      mp[flutter::EncodableValue("pagesCount")] =
          flutter::EncodableValue(doc->getPageCount());
      result->Success(mp);
    } catch (std::exception& e) {
      result->Error("pdfx_exception", e.what());
    }
  }

  ///
  /// Open document from data stream
  ///
  else if (method_call.method_name().compare(kOpenDocumentDataMethod) == 0) {
    auto data = std::get<std::vector<uint8_t>>(*method_call.arguments());

    try {
      std::shared_ptr<Document> doc = openDocument(data);

      auto mp = flutter::EncodableMap{};
      mp[flutter::EncodableValue("id")] = flutter::EncodableValue(doc->id);
      mp[flutter::EncodableValue("pagesCount")] =
          flutter::EncodableValue(doc->getPageCount());
      result->Success(mp);
    } catch (std::exception& e) {
      result->Error("pdfx_exception", e.what());
    }
  }

  ///
  /// Close document
  ///
  else if (method_call.method_name().compare(kCloseDocumentMethod) == 0) {
    auto id = std::get<std::string>(*method_call.arguments());
    closeDocument(id);
    result->Success();
  }

  ///
  /// Open page
  ///
  else if (method_call.method_name().compare(kOpenPageMethod) == 0) {
    const auto* arguments =
        std::get_if<flutter::EncodableMap>(method_call.arguments());

    auto vDocId = arguments->find(flutter::EncodableValue("documentId"));
    if (vDocId == arguments->end()) {
      result->Error("pdfx_exception", "documentId is required");
      return;
    }
    auto docId = std::get<std::string>(vDocId->second);

    auto vPageIndex = arguments->find(flutter::EncodableValue("page"));
    if (vPageIndex == arguments->end()) {
      result->Error("pdfx_exception", "page is required");
      return;
    }
    auto pageIndex = std::get<int>(vPageIndex->second) - 1;

    try {
      std::shared_ptr<Page> page = openPage(docId, pageIndex);
      auto details = page->getDetails();

      auto mp = flutter::EncodableMap{};
      mp[flutter::EncodableValue("id")] = flutter::EncodableValue(page->id);
      mp[flutter::EncodableValue("width")] =
          flutter::EncodableValue(details.width);
      mp[flutter::EncodableValue("height")] =
          flutter::EncodableValue(details.height);
      result->Success(mp);
    } catch (std::exception& e) {
      result->Error("pdfx_exception", e.what());
    }
  }

  ///
  /// Close page
  ///
  else if (method_call.method_name().compare(kClosePageMethod) == 0) {
    auto id = std::get<std::string>(*method_call.arguments());
    closePage(id);
    result->Success();
  }

  ///
  /// Render page to image
  ///
  else if (method_call.method_name().compare(kRenderMethod) == 0) {
    const auto* arguments =
        std::get_if<flutter::EncodableMap>(method_call.arguments());

    auto vPageId = arguments->find(flutter::EncodableValue("pageId"));
    if (vPageId == arguments->end()) {
      result->Error("pdfx_exception", "pageId is required");
      return;
    }
    auto pageId = std::get<std::string>(vPageId->second);

    auto vHeight = arguments->find(flutter::EncodableValue("height"));
    if (vHeight == arguments->end()) {
      result->Error("pdfx_exception", "height is required");
      return;
    }
    auto height = std::get<int>(vHeight->second);

    auto vWidth = arguments->find(flutter::EncodableValue("width"));
    if (vWidth == arguments->end()) {
      result->Error("pdfx_exception", "width is required");
      return;
    }
    auto width = std::get<int>(vWidth->second);

    auto vBackground =
        arguments->find(flutter::EncodableValue("backgroundColor"));
    if (vBackground == arguments->end()) {
      result->Error("pdfx_exception", "backgroundColor is required");
      return;
    }
    auto background = std::get<std::string>(vBackground->second);

    // Format
    auto vFormat = arguments->find(flutter::EncodableValue("format"));
    if (vWidth == arguments->end()) {
      result->Error("pdfx_exception", "width is required");
      return;
    }
    auto formatInt = std::get<int>(vFormat->second);

    ImageFormat format;
    switch (formatInt) {
      case 0:
        format = JPEG;
        break;
      case 1:
        format = PNG;
        break;
      default:
        result->Error("pdfx_exception", "Image encoder not implemented");
        return;
    }

    // Cropping
    auto vCrop = arguments->find(flutter::EncodableValue("crop"));
    if (vCrop == arguments->end()) {
      result->Error("pdfx_exception", "crop is required");
      return;
    }
    auto crop = std::get<bool>(vCrop->second);

    CropDetails* cropDetails = nullptr;
    if (crop) {
      cropDetails = new CropDetails();

      auto vCropX = arguments->find(flutter::EncodableValue("crop_x"));
      if (vCropX == arguments->end()) {
        result->Error("pdfx_exception", "crop_x is required");
        return;
      }
      cropDetails->crop_x = std::get<int>(vCropX->second);

      auto vCropY = arguments->find(flutter::EncodableValue("crop_y"));
      if (vCropY == arguments->end()) {
        result->Error("pdfx_exception", "crop_y is required");
        return;
      }
      cropDetails->crop_y = std::get<int>(vCropY->second);

      auto vCropWidth = arguments->find(flutter::EncodableValue("crop_width"));
      if (vCropWidth == arguments->end()) {
        result->Error("pdfx_exception", "crop_width is required");
        return;
      }
      cropDetails->crop_width = std::get<int>(vCropWidth->second);

      auto vCropHeight =
          arguments->find(flutter::EncodableValue("crop_height"));
      if (vCropHeight == arguments->end()) {
        result->Error("pdfx_exception", "crop_height is required");
        return;
      }
      cropDetails->crop_height = std::get<int>(vCropHeight->second);
    }

    try {
      auto render =
          renderPage(pageId, width, height, format, background, cropDetails);
      auto mp = flutter::EncodableMap{};
      mp[flutter::EncodableValue("data")] =
          flutter::EncodableValue(render.data);
      mp[flutter::EncodableValue("width")] =
          flutter::EncodableValue(render.width);
      mp[flutter::EncodableValue("height")] =
          flutter::EncodableValue(render.height);
      result->Success(mp);
    } catch (std::exception& e) {
      result->Error("pdfx_exception", e.what());
    }

    delete cropDetails;
  } else {
    result->NotImplemented();
  }
}

}  // namespace pdfx

void PdfxPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  pdfx::PdfxPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
