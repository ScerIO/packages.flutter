#pragma warning(disable : 4458)

// Windows imports
#include <Windows.h>
#include <gdiplus.h>

// std imports
#include <iostream>
#include <stdexcept>
#include <string>
#include <unordered_map>

#include "native_pdf_renderer.h"

#pragma comment(lib, "gdiplus.lib")

namespace native_pdf_renderer {
int GetEncoderClsid(const WCHAR* format, CLSID* pClsid) {
  UINT num = 0;   // number of image encoders
  UINT size = 0;  // size of the image encoder array in bytes

  Gdiplus::ImageCodecInfo* pImageCodecInfo = NULL;

  Gdiplus::GetImageEncodersSize(&num, &size);
  if (size == 0) return -1;  // Failure

  pImageCodecInfo = (Gdiplus::ImageCodecInfo*)(malloc(size));
  if (pImageCodecInfo == NULL) return -1;  // Failure

  GetImageEncoders(num, size, pImageCodecInfo);

  for (UINT j = 0; j < num; ++j) {
    if (wcscmp(pImageCodecInfo[j].MimeType, format) == 0) {
      *pClsid = pImageCodecInfo[j].Clsid;
      free(pImageCodecInfo);
      return j;  // Success
    }
  }

  free(pImageCodecInfo);
  return -1;  // Failure
}

std::unordered_map<std::string, std::shared_ptr<Document>> document_repository;
std::unordered_map<std::string, std::shared_ptr<Page>> page_repository;
int lastId = 0;

std::shared_ptr<Document> openDocument(std::vector<uint8_t> data) {
  if (document_repository.size() == 0) {
    FPDF_InitLibraryWithConfig(nullptr);
  }

  lastId++;
  std::string strId = std::to_string(lastId);

  std::shared_ptr<Document> doc = std::make_shared<Document>(data, strId);
  document_repository[strId] = doc;

  return doc;
}

std::shared_ptr<Document> openDocument(std::string name) {
  if (document_repository.size() == 0) {
    FPDF_InitLibraryWithConfig(nullptr);
  }

  lastId++;
  std::string strId = std::to_string(lastId);

  std::shared_ptr<Document> doc = std::make_shared<Document>(name, strId);
  document_repository[strId] = doc;

  return doc;
}

void closeDocument(std::string id) {
  document_repository.erase(id);

  if (document_repository.size() == 0) {
    FPDF_DestroyLibrary();
  }
}

std::shared_ptr<Page> openPage(std::string docId, int index) {
  lastId++;
  std::string strId = std::to_string(lastId);

  auto doc = document_repository.find(docId);
  if (doc == document_repository.end()) {
    throw std::invalid_argument("Document is not open");
  }

  std::shared_ptr<Page> page =
      std::make_shared<Page>(doc->second, index, strId);

  page_repository[strId] = page;

  return page;
}

void closePage(std::string id) { page_repository.erase(id); }

PageRender renderPage(std::string id, int width, int height, ImageFormat format,
                      std::string backgroundStr, CropDetails* crop) {
  auto page = page_repository.find(id);
  if (page == page_repository.end()) {
    throw std::invalid_argument("Page does not exist");
  }

  // Get background color
  backgroundStr.erase(0, 1);
  auto background = std::stoul(backgroundStr, nullptr, 16);

  // Render page
  return page->second->render(width, height, format, background, crop);
}

//

Document::Document(std::vector<uint8_t> dataRef, std::string id) : id{id} {
  // Copy data into object to keep it in memory
  data.swap(dataRef);

  document = FPDF_LoadMemDocument64(data.data(), data.size(), nullptr);
  if (!document) {
    throw std::invalid_argument("Document failed to open");
  }
}

Document::Document(std::string file, std::string id) : id{id} {
  document = FPDF_LoadDocument(file.c_str(), nullptr);
  if (!document) {
    throw std::invalid_argument("Document failed to open");
  }
}

Document::~Document() { FPDF_CloseDocument(document); }

int Document::getPageCount() { return FPDF_GetPageCount(document); }

Page::Page(std::shared_ptr<Document> doc, int index, std::string id) : id(id) {
  page = FPDF_LoadPage(doc->document, index);
  if (!page) {
    throw std::invalid_argument("Page failed to open");
  }
}

Page::~Page() { FPDF_ClosePage(page); }

PageDetails Page::getDetails() {
  int width = static_cast<int>(FPDF_GetPageWidthF(page) + 0.5f);
  int height = static_cast<int>(FPDF_GetPageHeightF(page) + 0.5f);

  return PageDetails(width, height);
}

PageRender Page::render(int width, int height, ImageFormat format,
                        unsigned long background, CropDetails* crop) {
  int rWidth, rHeight, start_x, size_x, start_y, size_y;
  if (crop == nullptr) {
    rWidth = width;
    rHeight = height;
    start_x = 0;
    size_x = width;
    start_y = 0;
    size_y = height;
  } else {
    rWidth = crop->crop_width;
    rHeight = crop->crop_height;

    start_x = 0 - crop->crop_x;
    size_x = width;
    start_y = 0 - crop->crop_y;
    size_y = height;
  }

  // Create empty bitmap and render page onto it
  auto bitmap = FPDFBitmap_Create(rWidth, rHeight, 0);
  FPDFBitmap_FillRect(bitmap, 0, 0, rWidth, rHeight, background);
  FPDF_RenderPageBitmap(bitmap, page, start_x, start_y, size_x, size_y, 0,
                        FPDF_ANNOT | FPDF_LCD_TEXT);

  // Convert bitmap into RGBA format
  uint8_t* p = static_cast<uint8_t*>(FPDFBitmap_GetBuffer(bitmap));
  auto stride = FPDFBitmap_GetStride(bitmap);

  // Convert to image format
  Gdiplus::GdiplusStartupInput gdiplusStartupInput;
  ULONG_PTR gdiplusToken;
  Gdiplus::GdiplusStartup(&gdiplusToken, &gdiplusStartupInput, NULL);

  // Get the CLSID of the image encoder.
  CLSID encoderClsid;
  switch (format) {
    case PNG:
      GetEncoderClsid(L"image/png", &encoderClsid);
      break;
    case JPEG:
      GetEncoderClsid(L"image/jpeg", &encoderClsid);
      break;
  }

  // Create gdi+ bitmap from raw image data
  auto winBitmap =
      new Gdiplus::Bitmap(rWidth, rHeight, stride, PixelFormat32bppRGB, p);

  // Create stream for converted image
  IStream* istream = nullptr;
  CreateStreamOnHGlobal(NULL, TRUE, &istream);

  // Encode image onto stream
  auto stat = winBitmap->Save(istream, &encoderClsid, NULL);
  if (stat == Gdiplus::OutOfMemory) {
    throw std::exception("Failed to encode to image, out of memory");
  } else if (stat != Gdiplus::Ok) {
    throw std::exception("Failed to encode to image");
  }

  // Get raw memory of stream
  HGLOBAL hg = NULL;
  GetHGlobalFromStream(istream, &hg);

  // copy IStream to buffer
  size_t bufsize = GlobalSize(hg);
  std::vector<uint8_t> data;
  data.resize(bufsize);

  // lock & unlock memory
  LPVOID pimage = GlobalLock(hg);
  memcpy(&data[0], pimage, bufsize);
  GlobalUnlock(hg);

  // Close stream
  istream->Release();

  // Cleanup gid+
  delete winBitmap;
  Gdiplus::GdiplusShutdown(gdiplusToken);

  FPDFBitmap_Destroy(bitmap);

  return PageRender(data, rWidth, rHeight);
}
}  // namespace native_pdf_renderer