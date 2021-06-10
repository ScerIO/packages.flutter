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

    func render(width: Int, height: Int, crop: CGRect?, compressFormat: CompressFormat, backgroundColor: UIColor, quality: Int) -> Page.DataResult? {
        let pdfBBox = renderer.getBoxRect(.mediaBox)
        let bitmapSize = isLandscape ? CGSize(width: height, height: width) : CGSize(width: width, height: height)
        let stride = Int(bitmapSize.width * 4)
        var tempData = Data(repeating: 0, count: stride * Int(bitmapSize.height))
        var data: Data?
        var fileURL: URL?
        var success = false
        let sx = CGFloat(width) / pdfBBox.width
        let sy = CGFloat(height) / pdfBBox.height
        let tx = isLandscape ? CGFloat(height) / 2 : CGFloat(0)
        let ty = CGFloat(0)
        let angle = CGFloat(renderer.rotationAngle) * CGFloat.pi / 180;
        let compressionQuality = CGFloat(quality) / 100
        tempData.withUnsafeMutableBytes { (ptr) in
            let rawPtr = ptr.baseAddress
            let rgb = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: rawPtr, width: Int(bitmapSize.width), height: Int(bitmapSize.height), bitsPerComponent: 8, bytesPerRow: stride, space: rgb, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            if context != nil {
                // TODO: Fix this! It doesn't work correctly on PDFs with weird rotational values
                // context!.translateBy(x: tx, y: ty)
                // context!.rotate(by: -angle)
                context!.scaleBy(x: sx, y: sy)
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
                        data = image.jpegData(compressionQuality: compressionQuality) as Data?
                        break;
                    case CompressFormat.PNG:
                        data = image.pngData() as Data?
                        break;
                }

                if data != nil {
                    fileURL = writeToTempFile(data: data!, compressFormat: compressFormat)
                }

                success = true
            }
        }
        return success ? Page.DataResult(
            width: (crop != nil) ? Int(crop!.width) : width,
            height: (crop != nil) ? Int(crop!.height) : height,
            path: (fileURL != nil) ? fileURL!.path : "",
            sx: Float(sx),
            sy: Float(sy),
            tx: Float(tx),
            ty: Float(ty),
            angle: Float(angle),
            deg: renderer.rotationAngle,
            boxWidth: Float(pdfBBox.width),
            boxheight: Float(pdfBBox.height),
            isLandscape: isLandscape
            ) : nil
    }

    func writeToTempFile(data: Data, compressFormat: CompressFormat) -> URL? {
        // Create missing directories
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let cacheURL = docURL.appendingPathComponent("native_pdf_renderer_cache")
        if !FileManager.default.fileExists(atPath: cacheURL.path) {
            do {
                try FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        // Create temporary filename
        let randomFileName = NSUUID().uuidString.replacingOccurrences(of: "-", with: "")
        var tempOutFileExtension: String?
        var tempOutFileName: String?
        switch(compressFormat) {
            case CompressFormat.JPEG:
                tempOutFileExtension = "jpg"
                break;
            case CompressFormat.PNG:
                tempOutFileExtension = "png"
                break;
            default:
                return nil
        }
        tempOutFileName = "\(randomFileName).\(tempOutFileExtension!)"
        let fileURL = cacheURL.appendingPathComponent(tempOutFileName!)
        // Write the data to the temporary file
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print(error.localizedDescription)
            return nil
        }
        return fileURL
    }

    class DataResult {
        let width: Int
        let height: Int
        let path: String
        // DEBUG
        let sx: Float
        let sy: Float
        let tx: Float
        let ty: Float
        let angle: Float
        let deg: Int32
        let boxWidth: Float
        let boxHeight: Float
        let isLandscape: Bool
        // DEBUG

        init(width: Int, height: Int, path: String,
        sx: Float,
        sy: Float,
        tx: Float,
        ty: Float,
        angle: Float,
        deg: Int32,
        boxWidth: Float,
        boxHeight: Float,
        isLandscape: Bool
        ) {
            self.width = width
            self.height = height
            self.path = path
            // DEBUG
            self.sx = sx
            self.sy = sy
            self.tx = tx
            self.ty = ty
            self.angle = angle
            self.deg = deg
            self.boxWidth = boxWidth
            self.boxHeight = boxHeight
            self.isLandscape = isLandscape
            // DEBUG
        }
    }
}

enum CompressFormat: Int {
    case JPEG = 0
    case PNG = 1
}
