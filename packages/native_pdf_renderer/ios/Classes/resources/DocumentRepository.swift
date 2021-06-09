class DocumentRepository : Repository<Document> {
    func register(renderer: PDFDocument) -> Document {
        let id = NSUUID().uuidString
        let page = Document(id: id, renderer: renderer)
        set(id: id, item: page)
        return page
    }
}
