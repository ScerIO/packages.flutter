package io.scer.native_pdf_renderer

import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.Build
import android.os.ParcelFileDescriptor
import android.util.Log
import androidx.annotation.RequiresApi
import dev.flutter.pigeon.Pigeon
import io.flutter.BuildConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.FlutterException
import io.scer.native_pdf_renderer.resources.DocumentRepository
import io.scer.native_pdf_renderer.resources.PageRepository
import io.scer.native_pdf_renderer.resources.RepositoryItemNotFoundException
import io.scer.native_pdf_renderer.utils.CreateRendererException
import io.scer.native_pdf_renderer.utils.randomFilename
import io.scer.native_pdf_renderer.utils.toFile
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException
import java.lang.RuntimeException

@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
class Messages(private val binding : FlutterPlugin.FlutterPluginBinding,
               private val documents: DocumentRepository,
               private val pages: PageRepository) : Pigeon.PdfRendererApi {

    override fun openDocumentData(
        message: Pigeon.OpenDataMessage,
        result: Pigeon.Result<Pigeon.OpenReply>
    ) {
        val resultResponse = Pigeon.OpenReply();
        try {
            val documentRenderer = openDataDocument(message.data)
            val document = documents.register(documentRenderer)
            resultResponse.id = document.id
            resultResponse.pagesCount = document.pagesCount.toLong()
            result.success(resultResponse)
        } catch (e: IOException) {
            result.error(PdfRendererException("PDF_RENDER", "Can't open file", null))
        } catch (e: CreateRendererException) {
            result.error(PdfRendererException("PDF_RENDER", "Can't create PDF renderer", null))
        } catch (e: Exception) {
            result.error(PdfRendererException("PDF_RENDER", "Unknown error", null))
        }
    }

    override fun openDocumentFile(
        message: Pigeon.OpenPathMessage,
        result: Pigeon.Result<Pigeon.OpenReply>
    ) {
        val resultResponse = Pigeon.OpenReply();
        try {
            val path = message.path
            val documentRenderer = openFileDocument(File(path))
            val document = documents.register(documentRenderer)
            resultResponse.id = document.id
            resultResponse.pagesCount = document.pagesCount.toLong()
            result.success(resultResponse)
        } catch (e: NullPointerException) {
            result.error(PdfRendererException("PDF_RENDER", "Need call arguments: path", null))
        } catch (e: FileNotFoundException) {
            result.error(PdfRendererException("PDF_RENDER", "File not found", null))
        } catch (e: IOException) {
            result.error(PdfRendererException("PDF_RENDER", "Can't open file", null))
        } catch (e: CreateRendererException) {
            result.error(PdfRendererException("PDF_RENDER", "Can't create PDF renderer", null))
        } catch (e: Exception) {
            result.error(PdfRendererException("PDF_RENDER", "Unknown error", null))
        }
    }

    override fun openDocumentAsset(
        message: Pigeon.OpenPathMessage,
        result: Pigeon.Result<Pigeon.OpenReply>
    ) {
        val resultResponse = Pigeon.OpenReply();
        try {
            val path = message.path
            val documentRenderer = openAssetDocument(path)
            val document = documents.register(documentRenderer)
            resultResponse.id = document.id
            resultResponse.pagesCount = document.pagesCount.toLong()
            result.success(resultResponse)
        } catch (e: NullPointerException) {
            result.error(PdfRendererException("PDF_RENDER", "Need call arguments: path", null))
        } catch (e: FileNotFoundException) {
            result.error(PdfRendererException("PDF_RENDER", "File not found", null))
        } catch (e: IOException) {
            result.error(PdfRendererException("PDF_RENDER", "Can't open file", null))
        } catch (e: CreateRendererException) {
            result.error(PdfRendererException("PDF_RENDER", "Can't create PDF renderer", null))
        } catch (e: Exception) {
            result.error(PdfRendererException("PDF_RENDER", "Unknown error", null))
        }
    }

    override fun closeDocument(message: Pigeon.IdMessage) {
        try {
            val id = message.id
            documents.close(id)
        } catch (e: NullPointerException) {
            throw PdfRendererException("PDF_RENDER", "Need call arguments: id!", null)
        } catch (e: RepositoryItemNotFoundException) {
            throw PdfRendererException("PDF_RENDER", "Document not exist in documents repository", null)
        } catch (e: Exception) {
            throw PdfRendererException("PDF_RENDER", "Unknown error", null)
        }
    }

    override fun getPage(
        message: Pigeon.GetPageMessage,
        result: Pigeon.Result<Pigeon.GetPageReply>
    ) {
        val resultResponse = Pigeon.GetPageReply()
        try {
            val documentId = message.documentId
            val pageNumber = message.pageNumber.toInt()

            val pageRenderer = documents.get(documentId).openPage(pageNumber)
            val page = pages.register(documentId, pageRenderer)
            resultResponse.id = page.id
            resultResponse.width = page.width.toLong()
            resultResponse.height = page.height.toLong()

            result.success(resultResponse)
        } catch (e: NullPointerException) {
            result.error(PdfRendererException("PDF_RENDER", "Need call arguments: documentId & page!", null))
        } catch (e: RepositoryItemNotFoundException) {
            result.error(PdfRendererException("PDF_RENDER", "Document not exist in documents", null))
        } catch (e: Exception) {
            result.error(PdfRendererException("PDF_RENDER", "Unknown error", null))
        }
    }

    override fun renderPage(
        message: Pigeon.RenderPageMessage,
        result: Pigeon.Result<Pigeon.RenderPageReply>
    ) {
        val resultResponse = Pigeon.RenderPageReply()
        try {
            val pageId = message.pageId
            val width = message.width.toInt()
            val height = message.height.toInt()
            val format = message.format.toInt() ?: 1 //0 Bitmap.CompressFormat.PNG
            val backgroundColor = message.backgroundColor
            val color = if (backgroundColor != null) Color.parseColor(backgroundColor) else Color.TRANSPARENT

            val crop = message.crop
            val cropX = if (crop) message.cropX.toInt() else 0;
            val cropY = if (crop) message.cropY.toInt() else 0;
            val cropH = if (crop) message.cropHeight.toInt() else 0;
            val cropW = if (crop) message.width.toInt() else 0;

            val quality = message.quality.toInt() ?: 100

            val page = pages.get(pageId)

            val tempOutFileExtension = when (format) {
                0 -> "jpg"
                1 -> "png"
                2 -> "webp"
                else -> "jpg"
            }
            val tempOutFolder = File(binding.applicationContext.cacheDir, "native_pdf_renderer_cache")
            tempOutFolder.mkdirs()
            val tempOutFile = File(tempOutFolder, "$randomFilename.$tempOutFileExtension")

            val pageImage = page.render(tempOutFile, width, height, color, format, crop, cropX, cropY, cropW, cropH, quality)
            resultResponse.path = pageImage.path
            resultResponse.width = pageImage.width.toLong()
            resultResponse.height = pageImage.height.toLong()
            result.success(resultResponse)

        } catch (e: Exception) {
            result.error(PdfRendererException("PDF_RENDER", "Unexpected error", e))
        }
    }

    override fun closePage(message: Pigeon.IdMessage) {
        try {
            val id = message.id
            pages.close(id)
        } catch (e: NullPointerException) {
            throw PdfRendererException("PDF_RENDER", "Need call arguments: id!", null)
        } catch (e: RepositoryItemNotFoundException) {
            throw PdfRendererException("PDF_RENDER", "Page not exist in pages repository", null)
        } catch (e: Exception) {
            throw PdfRendererException("PDF_RENDER", "Unknown error", null)
        }
    }

    private fun openDataDocument(data: ByteArray): Pair<ParcelFileDescriptor, PdfRenderer>? {
        val tempDataFile = File(binding.applicationContext.cacheDir, "$randomFilename.pdf")
        if (!tempDataFile.exists()) {
            tempDataFile.writeBytes(data)
        }
        Log.d("PDF_RENDER", "OpenDataDocument. Created file: " + tempDataFile.path)
        return openFileDocument(tempDataFile)
    }

    private fun openAssetDocument(assetPath: String): Pair<ParcelFileDescriptor, PdfRenderer>?{
        val fullAssetPath = binding.flutterAssets.getAssetFilePathByName(assetPath)
        val tempAssetFile = File(binding.applicationContext.cacheDir, "$randomFilename.pdf")
        if (!tempAssetFile.exists()) {
            val inputStream = binding.applicationContext.assets.open(fullAssetPath)
            inputStream.toFile(tempAssetFile)
            inputStream.close()
        }
        Log.d("PDF_RENDER", "OpenAssetDocument. Created file: " + tempAssetFile.path)
        return openFileDocument(tempAssetFile)
    }

    private fun openFileDocument(file: File): Pair<ParcelFileDescriptor, PdfRenderer> {
        Log.d("PDF_RENDER", "OpenFileDocument. File: " + file.path)
        val fileDescriptor = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
        return if (fileDescriptor != null) {
            val pdfRenderer = PdfRenderer(fileDescriptor)
            Pair(fileDescriptor, pdfRenderer)
        } else throw CreateRendererException()
    }
}

class PdfRendererException internal constructor(code: String?, message: String?, details: Any?) :
    RuntimeException(message) {
    private val code: String?
    private var details: Any? = null

    companion object {
        private const val TAG = "PdfRendererException#"
    }

    init {
        if (BuildConfig.DEBUG && code == null) {
            io.flutter.Log.e(PdfRendererException.Companion.TAG, "Parameter code must not be null.")
        }
        this.code = code
        if (details != null) {
            this.details = details
        }
    }
}
