class Page {
    let id: String
    let documentId: String
    let renderer: CGPDFPage
    let boxRect: CGRect

    init(id: String, documentId: String, renderer: CGPDFPage) {
        self.id = id
        self.documentId = documentId
        self.renderer = renderer
        self.boxRect = renderer.getBoxRect(.mediaBox)
    }

    var number: Int {
        get {
            return renderer.pageNumber
        }
    }

    var width: Int {
        get {
            return Int(boxRect.width)
        }
    }

    var height: Int {
        get {
            return Int(boxRect.height)
        }
    }

    var infoMap: [String: Any] {
        get {
            return [
                "documentId": documentId,
                "id": id,
                "pageNumber": Int32(number),
                "width": Int32(width),
                "height": Int32(height)
            ]
        }
    }

    func render(width: Int, height: Int, compressFormat: CompressFormat, backgroundColor: UIColor) -> Page.DataResult? {
        let pdfBBox = renderer.getBoxRect(.mediaBox)
        let stride = width * 4
        var tempData = Data(repeating: backgroundColor.toBytes(), count: stride * height)
        var data: Data?
        var success = false
        let sx = CGFloat(width) / pdfBBox.width
        let sy = CGFloat(height) / pdfBBox.height
        tempData.withUnsafeMutableBytes { (ptr: UnsafeMutablePointer<UInt8>) in
            let rgb = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: ptr, width: width, height: height, bitsPerComponent: 8, bytesPerRow: stride, space: rgb, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            if context != nil {
                context!.scaleBy(x: sx, y: sy)
                context!.drawPDFPage(renderer)
                let image = UIImage(cgImage: context!.makeImage()!)
                switch(compressFormat) {
                    case CompressFormat.JPEG:
                        data = image.jpegData(compressionQuality: 1.0) as Data?
                        success = true
                        break;
                    case CompressFormat.PNG:
                        data = image.pngData() as Data?
                        success = true
                        break;
                }
            }
        }
        return success ? Page.DataResult(
            width: width,
            height: height,
            data: data!) : nil
    }

    class DataResult {
        let width: Int
        let height: Int
        let data: Data

        init(width: Int, height: Int, data: Data) {
            self.width = width
            self.height = height
            self.data = data
        }
    }
}

enum CompressFormat: Int {
    case JPEG = 0
    case PNG = 1
}
