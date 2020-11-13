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
    
    var rotationAngle: Int32 {
        get {
            return renderer.rotationAngle
        }
    }

    var isLandscape: Bool {
        get {
            return Bool(rotationAngle == 90 || rotationAngle == 270)
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

    func render(width: Int, height: Int, crop: CGRect?, compressFormat: CompressFormat, backgroundColor: UIColor) -> Page.DataResult? {
        let pdfBBox = renderer.getBoxRect(.mediaBox)
        let bitmapSize = isLandscape ? CGSize(width: height, height: width) : CGSize(width: width, height: height)
        let stride = Int(bitmapSize.width * 4)
        var tempData = Data(repeating: 0, count: stride * Int(bitmapSize.height))
        var data: Data?
        var success = false
        let sx = CGFloat(width) / pdfBBox.width
        let sy = CGFloat(height) / pdfBBox.height
        let tx = isLandscape ? CGFloat(height) / 2 : CGFloat(0)
        let ty = CGFloat(0)
        let angle = CGFloat(renderer.rotationAngle) * CGFloat.pi / 180;
        tempData.withUnsafeMutableBytes { (ptr) in
            let rawPtr = ptr.baseAddress
            let rgb = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: rawPtr, width: Int(bitmapSize.width), height: Int(bitmapSize.height), bitsPerComponent: 8, bytesPerRow: stride, space: rgb, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            if context != nil {
                context!.scaleBy(x: sx, y: sy)
                context!.translateBy(x: tx, y: ty)
                context!.rotate(by: -angle)
                context!.setFillColor(backgroundColor.cgColor)
                context!.fill(pdfBBox)
                context!.drawPDFPage(renderer)
                var image = UIImage(cgImage: context!.makeImage()!)

                if (crop != nil){
                    // Perform cropping in Core Graphics
                    let cutImageRef: CGImage = (image.cgImage?.cropping(to:crop!))!
                    image = UIImage(cgImage: cutImageRef)
                }

                switch(compressFormat) {
                    case CompressFormat.JPEG:
                        data = image.jpegData(compressionQuality: 1.0) as Data?
                        break;
                    case CompressFormat.PNG:
                        data = image.pngData() as Data?
                        break;
                }

                success = true
            }
        }
        return success ? Page.DataResult(
            width: (crop != nil) ? Int(crop!.width) : width,
            height: (crop != nil) ? Int(crop!.height) : height,
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
