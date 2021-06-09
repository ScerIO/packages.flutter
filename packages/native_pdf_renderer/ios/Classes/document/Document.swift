class Document {
    let id: String
    let renderer: CGPDFDocument
    var pages: [CGPDFPage?]
    
    init(id: String, renderer: CGPDFDocument) {
        self.id = id
        self.renderer = renderer
        self.pages = Array<CGPDFPage?>(repeating: nil, count: renderer.numberOfPages)
    }
    
    var pagesCount: Int {
        get {
            return renderer.numberOfPages
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
    public func openPage(pageNumber: Int) -> CGPDFPage? {
        return renderer.page(at: pageNumber)
    }
}
