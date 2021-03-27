#ifndef NATIVE_PDF_RENDERER_H_
#define NATIVE_PDF_RENDERER_H_

#include <vector>
#include <string>
#include <memory>

#include <fpdfview.h>

namespace native_pdf_renderer
{

    struct PageDetails
    {
        const int width;
        const int height;

        PageDetails(int width, int height) : width(width), height(height) {}
    };

    struct PageRender
    {
        const std::vector<uint8_t> data;
        const int width;
        const int height;

        PageRender(std::vector<uint8_t> data, int width, int height) : data(data), width(width), height(height) {}
    };

    class Document
    {
    private:
    public:
        Document(std::vector<uint8_t> data, std::string id);
        Document(std::string file, std::string id);

        ~Document();

        std::string id;
        FPDF_DOCUMENT document;

        int getPageCount(void);
    };

    class Page
    {
    private:
        FPDF_PAGE page;

    public:
        Page(std::shared_ptr<Document> doc, int index, std::string id);
        ~Page();

        std::string id;

        PageDetails getDetails();
        PageRender render(int width, int height);
    };

    std::shared_ptr<Document> openDocument(std::vector<uint8_t> data);
    std::shared_ptr<Document> openDocument(std::string name);

    void closeDocument(std::string id);
    std::shared_ptr<Page> openPage(std::string docId, int index);
    void closePage(std::string id);
    PageRender renderPage(std::string id, int width, int height);

}

#endif