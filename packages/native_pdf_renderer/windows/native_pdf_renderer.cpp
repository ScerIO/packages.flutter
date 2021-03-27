#include <string>
#include <unordered_map>
#include <iostream>

#include "native_pdf_renderer.h"
#include "libs/lodepng.h"

namespace native_pdf_renderer
{
    std::unordered_map<std::string, std::shared_ptr<Document>> document_repository;
    std::unordered_map<std::string, std::shared_ptr<Page>> page_repository;
    int lastId = 0;

    std::shared_ptr<Document> openDocument(std::vector<uint8_t> data)
    {
        if (document_repository.size() == 0)
        {
            FPDF_InitLibraryWithConfig(nullptr);
        }

        lastId++;
        std::string strId = std::to_string(lastId);

        std::shared_ptr<Document> doc = std::make_shared<Document>(data, strId);
        document_repository[strId] = doc;

        return doc;
    }

    std::shared_ptr<Document> openDocument(std::string name)
    {
        if (document_repository.size() == 0)
        {
            FPDF_InitLibraryWithConfig(nullptr);
        }

        lastId++;
        std::string strId = std::to_string(lastId);

        std::shared_ptr<Document> doc = std::make_shared<Document>(name, strId);
        document_repository[strId] = doc;

        return doc;
    }

    void closeDocument(std::string id)
    {
        document_repository.erase(id);

        if (document_repository.size() == 0)
        {
            FPDF_DestroyLibrary();
        }
    }

    std::shared_ptr<Page> openPage(std::string docId, int index)
    {
        lastId++;
        std::string strId = std::to_string(lastId);

        std::shared_ptr<Document> doc = document_repository[docId];
        std::shared_ptr<Page> page = std::make_shared<Page>(doc, index, strId);

        page_repository[strId] = page;

        return page;
    }

    void closePage(std::string id)
    {
        page_repository.erase(id);
    }

    PageRender renderPage(std::string id, int width, int height)
    {
        return page_repository[id]->render(width, height);
    }

    //

    Document::Document(std::vector<uint8_t> data, std::string id) : id{id}
    {
        std::cout << "Document created" << std::endl;
        document = FPDF_LoadMemDocument64(data.data(), data.size(), nullptr);
    }

    Document::Document(std::string file, std::string id) : id{id}
    {
        std::cout << "Document created" << std::endl;
        document = FPDF_LoadDocument(file.c_str(), nullptr);
    }

    Document::~Document()
    {
        std::cout << "Document deleted" << std::endl;
        FPDF_CloseDocument(document);
    }

    int Document::getPageCount()
    {
        return FPDF_GetPageCount(document);
    }

    Page::Page(std::shared_ptr<Document> doc, int index, std::string id) : id(id)
    {
        std::cout << "Page created" << std::to_string(index) << std::endl;
        page = FPDF_LoadPage(doc->document, index);
    }

    Page::~Page()
    {
        std::cout << "Page deleted" << std::endl;
        FPDF_ClosePage(page);
    }

    PageDetails Page::getDetails()
    {
        std::cout << "Page got details" << std::endl;
        int width = static_cast<int>(FPDF_GetPageWidthF(page) + 0.5f);
        int height = static_cast<int>(FPDF_GetPageHeightF(page) + 0.5f);

        return PageDetails(width, height);
    }

    PageRender Page::render(int width, int height)
    {
        std::cout << "Page rendered" << std::endl;
        // auto page = FPDF_LoadPage(document, index);
        // if (!page)
        // {
        //     return null;
        // }
        auto mwidth = FPDF_GetPageWidth(page);

        auto bitmap = FPDFBitmap_Create(width, height, 0);
        FPDFBitmap_FillRect(bitmap, 0, 0, width, height, 0xffffffff);

        FPDF_RenderPageBitmap(bitmap, page, 0, 0, width, height, 0, FPDF_ANNOT | FPDF_LCD_TEXT);
        // FPDF_RenderPageBitmap(bitmap, page, 0, 0, width, height, 0, 0);

        uint8_t *p = static_cast<uint8_t *>(FPDFBitmap_GetBuffer(bitmap));
        auto stride = FPDFBitmap_GetStride(bitmap);
        size_t l = static_cast<size_t>(height * stride);

        // BGRA to RGBA conversion
        for (auto y = 0; y < height; y++)
        {
            auto offset = y * stride;
            for (auto x = 0; x < width; x++)
            {
                auto t = p[offset];
                p[offset] = p[offset + 2];
                p[offset + 2] = t;
                offset += 4;
            }
        }

        std::vector<uint8_t> bmp = {p, p + l};

        std::vector<unsigned char> png;
        unsigned error = lodepng::encode(png, bmp, width, height);

        if (error)
        {
            std::cout << "PNG encoding error " << error << ": " << lodepng_error_text(error) << std::endl;
        }

        FPDFBitmap_Destroy(bitmap);

        std::cout << "Page render complete" << std::endl;
        return PageRender(png, width, height);
    }
}