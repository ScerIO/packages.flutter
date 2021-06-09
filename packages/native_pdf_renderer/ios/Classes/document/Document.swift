class Document {
    let id: String
    let renderer: PDFDocument
    var pages: [PDFPage?]
    
    init(id: String, renderer: PDFDocument) {
        self.id = id
        self.renderer = renderer
        self.pages = Array<PDFPage?>(repeating: nil, count: renderer.pageCount)
    }
    
    var pagesCount: Int {
        get {
            return renderer.pageCount
        }
    }
    
    var infoMap: [String: Any] {
        get {
            return [
                "id": id,
                "pagesCount": Int32(pagesCount)
            ]
        }
    }
    
    /**
     * Open page by page number (not index!)
     */
    public func openPage(pageNumber: Int) -> PDFPage? {
        return renderer.page(at: pageNumber)
    }
}
