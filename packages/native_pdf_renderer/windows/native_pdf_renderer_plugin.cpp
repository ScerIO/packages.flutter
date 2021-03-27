#include "include/native_pdf_renderer/native_pdf_renderer_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>
#include <iostream>

#include "native_pdf_renderer.h"
// #include <fpdfview.h>

namespace native_pdf_renderer
{

  const char kOpenDocumentDataMethod[] = "open.document.data";
  const char kOpenDocumentFileMethod[] = "open.document.file";
  const char kOpenDocumentAssetMethod[] = "open.document.asset";
  const char kOpenPageMethod[] = "open.page";
  const char kCloseDocumentMethod[] = "close.document";
  const char kClosePageMethod[] = "close.page";
  const char kRenderMethod[] = "render";

  class NativePdfRendererPlugin : public flutter::Plugin
  {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    NativePdfRendererPlugin();

    virtual ~NativePdfRendererPlugin();

  private:
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  };

  // static
  void NativePdfRendererPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "io.scer.native_pdf_renderer",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<NativePdfRendererPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result) {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  NativePdfRendererPlugin::NativePdfRendererPlugin() {}

  NativePdfRendererPlugin::~NativePdfRendererPlugin() {}

  void NativePdfRendererPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (method_call.method_name().compare(kOpenDocumentAssetMethod) == 0)
    {
      auto name = std::get<std::string>(*method_call.arguments());

      auto mp = flutter::EncodableMap{};
      mp[flutter::EncodableValue("id")] = flutter::EncodableValue(name);
      mp[flutter::EncodableValue("pagesCount")] = flutter::EncodableValue(4);
      result->Success(mp);
    }
    else if (method_call.method_name().compare(kOpenDocumentFileMethod) == 0)
    {
      auto name = std::get<std::string>(*method_call.arguments());

      std::shared_ptr<Document> doc = openDocument(name);

      auto mp = flutter::EncodableMap{};
      mp[flutter::EncodableValue("id")] = flutter::EncodableValue(doc->id);
      mp[flutter::EncodableValue("pagesCount")] = flutter::EncodableValue(doc->getPageCount());
      result->Success(mp);
    }
    else if (method_call.method_name().compare(kOpenDocumentDataMethod) == 0)
    {
      auto data = std::get<std::vector<uint8_t>>(*method_call.arguments());

      // auto document = std::make_unique<Document>(data);

      // FPDF_InitLibraryWithConfig(nullptr);

      // FPDF_DOCUMENT doc = FPDF_LoadMemDocument64(data.data(), data.size(), nullptr);
      // if (!doc)
      // {
      //   FPDF_DestroyLibrary();
      //   result->Error("Argument error", "Could not open document");
      //   return;
      // }

      // auto pageCount = FPDF_GetPageCount(doc);

      // FPDF_CloseDocument(doc);

      // FPDF_DestroyLibrary();

      // auto mp = flutter::EncodableMap{};
      // mp[flutter::EncodableValue("id")] = flutter::EncodableValue("pdf_id");
      // mp[flutter::EncodableValue("pagesCount")] = flutter::EncodableValue(document->getPageCount());
      // result->Success(mp);

      std::shared_ptr<Document> doc = openDocument(data);
      auto mp = flutter::EncodableMap{};
      mp[flutter::EncodableValue("id")] = flutter::EncodableValue(doc->id);
      mp[flutter::EncodableValue("pagesCount")] = flutter::EncodableValue(doc->getPageCount());
      result->Success(mp);
    }
    else if (method_call.method_name().compare(kCloseDocumentMethod) == 0)
    {
      auto id = std::get<std::string>(*method_call.arguments());
      closeDocument(id);
      result->Success();
    }
    else if (method_call.method_name().compare(kOpenPageMethod) == 0)
    {
      const auto *arguments =
          std::get_if<flutter::EncodableMap>(method_call.arguments());

      auto vDocId = arguments->find(flutter::EncodableValue("documentId"));
      auto docId = std::get<std::string>(vDocId->second);

      auto vPageIndex = arguments->find(flutter::EncodableValue("page"));
      auto pageIndex = std::get<int>(vPageIndex->second) - 1;

      std::shared_ptr<Page> page = openPage(docId, pageIndex);
      auto details = page->getDetails();

      auto mp = flutter::EncodableMap{};
      mp[flutter::EncodableValue("id")] = flutter::EncodableValue(page->id);
      mp[flutter::EncodableValue("width")] = flutter::EncodableValue(details.width);
      mp[flutter::EncodableValue("height")] = flutter::EncodableValue(details.height);
      result->Success(mp);
    }
    else if (method_call.method_name().compare(kClosePageMethod) == 0)
    {
      auto id = std::get<std::string>(*method_call.arguments());
      closePage(id);
      result->Success();
    }
    else if (method_call.method_name().compare(kRenderMethod) == 0)
    {
      const auto *arguments =
          std::get_if<flutter::EncodableMap>(method_call.arguments());

      auto vPageId = arguments->find(flutter::EncodableValue("pageId"));
      auto pageId = std::get<std::string>(vPageId->second);

      auto vHeight = arguments->find(flutter::EncodableValue("height"));
      auto height = std::get<int>(vHeight->second);

      auto vWidth = arguments->find(flutter::EncodableValue("width"));
      auto width = std::get<int>(vWidth->second);

      auto render = renderPage(pageId, width, height);
      std::cout << "Page rendered size: " << std::to_string(render.data.size()) << std::endl;
      auto mp = flutter::EncodableMap{};
      mp[flutter::EncodableValue("data")] = flutter::EncodableValue(render.data);
      mp[flutter::EncodableValue("width")] = flutter::EncodableValue(render.width);
      mp[flutter::EncodableValue("height")] = flutter::EncodableValue(render.height);
      result->Success(mp);
    }
    else if (method_call.method_name().compare("getPlatformVersion") == 0)
    {
      std::ostringstream version_stream;
      version_stream << "Windows ";
      if (IsWindows10OrGreater())
      {
        version_stream << "10+";
      }
      else if (IsWindows8OrGreater())
      {
        version_stream << "8";
      }
      else if (IsWindows7OrGreater())
      {
        version_stream << "7";
      }
      result->Success(flutter::EncodableValue(version_stream.str()));
    }
    else
    {
      result->NotImplemented();
    }
  }

} // namespace

void NativePdfRendererPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
  native_pdf_renderer::NativePdfRendererPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
