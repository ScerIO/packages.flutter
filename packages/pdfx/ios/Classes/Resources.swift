enum RepositoryError: Error {
    case ItemNotFound
}

class Repository<T> {
    var items: [String: T] = [:]

    public func get(id: String) throws -> T {
        if !exist(id: id) {
            throw RepositoryError.ItemNotFound
        }
        return items[id]!
    }

    public func set(id: String, item: T) {
        items[id] = item
    }

    private func exist(id: String) -> Bool {
        return items.keys.contains(id)
    }

    open func close(id: String) {
        items.removeValue(forKey: id)
    }
}

class DocumentRepository : Repository<Document> {
    func register(renderer: CGPDFDocument) -> Document {
        let id = NSUUID().uuidString
        let page = Document(id: id, renderer: renderer)
        set(id: id, item: page)
        return page
    }
}

class PageRepository : Repository<Page> {
    func register(documentId: String, renderer: CGPDFPage) -> Page {
        let id = NSUUID().uuidString
        let page = Page(id: id, documentId: documentId, renderer: renderer)
        set(id: id, item: page)
        return page
    }
}
