#ifndef pdfx_H_
#define pdfx_H_

#include <fpdfview.h>

#include <memory>
#include <string>
#include <vector>

namespace pdfx {
enum ImageFormat {
  JPEG = 0,
  PNG = 1,
};

struct CropDetails {
  int crop_x;
  int crop_y;
  int crop_height;
  int crop_width;
};

struct PageDetails {
  const int width;
  const int height;

  PageDetails(int width, int height) : width(width), height(height) {}
};

struct PageRender {
  const std::vector<uint8_t> data;
  const int width;
  const int height;

  PageRender(std::vector<uint8_t> data, int width, int height)
      : data(data), width(width), height(height) {}
};

class Document {
 private:
  std::vector<uint8_t> data;

 public:
  Document(std::vector<uint8_t> data, std::string id);
  Document(std::string file, std::string id);

  ~Document();

  std::string id;
  FPDF_DOCUMENT document;

  int getPageCount(void);
};

class Page {
 private:
  FPDF_PAGE page;

 public:
  Page(std::shared_ptr<Document> doc, int index, std::string id);
  ~Page();

  std::string id;

  PageDetails getDetails();
  PageRender render(int width, int height, ImageFormat format,
                    unsigned long background, CropDetails* crop);
};

std::shared_ptr<Document> openDocument(std::vector<uint8_t> data);
std::shared_ptr<Document> openDocument(std::string name);

void closeDocument(std::string id);
std::shared_ptr<Page> openPage(std::string docId, int index);
void closePage(std::string id);
PageRender renderPage(std::string id, int width, int height, ImageFormat format,
                      std::string backgroundStr, CropDetails* crop);

}  // namespace pdfx

#endif
