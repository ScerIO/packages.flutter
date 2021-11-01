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
    
    /**
     * Open page by page number (not index!)
     */
    public func openPage(pageNumber: Int) -> CGPDFPage? {
        return renderer.page(at: pageNumber)
    }
}
