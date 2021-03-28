#include "include/native_pdf_renderer/native_pdf_renderer_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>
#include <iostream>

#include <pathcch.h>
#pragma comment(lib, "pathcch.lib")

#include <shlwapi.h>
#pragma comment(lib, "shlwapi.lib")

#include "native_pdf_renderer.h"

namespace native_pdf_renderer
{

  // Convert a wide Unicode string to an UTF8 string
  std::string utf8_encode(const std::wstring &wstr)
  {
    if (wstr.empty())
      return std::string();
    int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL);
    std::string strTo(size_needed, 0);
    WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), &strTo[0], size_needed, NULL, NULL);
    return strTo;
  }

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

      // Get .exe base path
      WCHAR basePath[MAX_PATH];
      GetModuleFileNameW(NULL, basePath, MAX_PATH);
#if (NTDDI_VERSION >= NTDDI_WIN8)
      PathCchRemoveFileSpec(basePath, MAX_PATH);
#else
      PathRemoveFileSpec(basePath);
#endif

      // Construct new path
      std::string path = utf8_encode(basePath) + "\\data\\flutter_assets\\" + name;

      std::shared_ptr<Document> doc = openDocument(path);

      auto mp = flutter::EncodableMap{};
      mp[flutter::EncodableValue("id")] = flutter::EncodableValue(doc->id);
      mp[flutter::EncodableValue("pagesCount")] = flutter::EncodableValue(doc->getPageCount());
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

      auto vFormat = arguments->find(flutter::EncodableValue("format"));
      auto formatInt = std::get<int>(vFormat->second);

      ImageFormat format;
      switch (formatInt)
      {
      case 0:
        format = JPEG;
        break;
      case 1:
        format = PNG;
        break;
      default:
        result->NotImplemented();
        return;
      }

      auto render = renderPage(pageId, width, height, format);
      std::cout << "Page rendered size: " << std::to_string(render.data.size()) << std::endl;
      auto mp = flutter::EncodableMap{};
      mp[flutter::EncodableValue("data")] = flutter::EncodableValue(render.data);
      mp[flutter::EncodableValue("width")] = flutter::EncodableValue(render.width);
      mp[flutter::EncodableValue("height")] = flutter::EncodableValue(render.height);
      result->Success(mp);
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
