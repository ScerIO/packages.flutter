class PageRepository : Repository<Page> {
    func register(documentId: String, renderer: PDFPage) -> Page {
        let id = NSUUID().uuidString
        let page = Page(id: id, documentId: documentId, renderer: renderer)
        set(id: id, item: page)
        return page
    }
}
