package io.scer.pdf.renderer

import android.annotation.TargetApi
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.Build
import android.os.ParcelFileDescriptor
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.scer.pdf.renderer.resources.DocumentRepository
import io.scer.pdf.renderer.resources.PageRepository
import io.scer.pdf.renderer.resources.RepositoryItemNotFoundException
import io.scer.pdf.renderer.utils.CreateRendererException
import io.scer.pdf.renderer.utils.randomFilename
import io.scer.pdf.renderer.utils.toFile
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException

/**
 * NativePDFRendererPlugin
 */
@TargetApi(Build.VERSION_CODES.LOLLIPOP)
class NativePDFRendererPlugin private constructor(private val registrar: Registrar) : MethodCallHandler {
    private val documents = DocumentRepository()
    private val pages = PageRepository()

    override fun onMethodCall(call: MethodCall, result: Result) {
        when(call.method) {
            "open.document.data" -> openDocumentDataHandler(call, result)
            "open.document.file" -> openDocumentFileHandler(call, result)
            "open.document.asset" -> openDocumentAssetHandler(call, result)
            "open.page" -> openPageHandler(call, result)
            "close.document" -> closeDocumentHandler(call, result)
            "close.page" -> closePageHandler(call, result)
            "render" -> renderHandler(call, result)
            else -> result.notImplemented()
        }
    }

    private fun openDocumentDataHandler(call: MethodCall, result: Result) {
        try {
            val data = call.arguments<ByteArray>()!!
            Thread {
                val documentRenderer = openDataDocument(data)
                result.success(documents.register(documentRenderer).infoMap)
            }.start()
        } catch (e: NullPointerException) {
            result.error("PDF_RENDER", "Need call arguments: data!", null)
        } catch (e: IOException) {
            result.error("PDF_RENDER", "Can't open file", null)
        } catch (e: CreateRendererException) {
            result.error("PDF_RENDER", "Can't create PDF renderer", null)
        }
    }

    private fun openDocumentFileHandler(call: MethodCall, result: Result) {
        try {
            val path = call.arguments<String>()!!
            Thread {
                val documentRenderer = openFileDocument(File(path))
                result.success(documents.register(documentRenderer).infoMap)
            }.start()
        } catch (e: NullPointerException) {
            result.error("PDF_RENDER", "Need call arguments: path", null)
        } catch (e: FileNotFoundException) {
            result.error("PDF_RENDER", "File not found", null)
        } catch (e: IOException) {
            result.error("PDF_RENDER", "Can't open file", null)
        } catch (e: CreateRendererException) {
            result.error("PDF_RENDER", "Can't create PDF renderer", null)
        }
    }

    private fun openDocumentAssetHandler(call: MethodCall, result: Result) {
        try {
            val path = call.arguments<String>()!!
            Thread {
                val documentRenderer = openAssetDocument(path)
                result.success(documents.register(documentRenderer).infoMap)
            }.start()
        } catch (e: NullPointerException) {
            result.error("PDF_RENDER", "Need call arguments: path", null)
        } catch (e: FileNotFoundException) {
            result.error("PDF_RENDER", "File not found", null)
        } catch (e: IOException) {
            result.error("PDF_RENDER", "Can't open file", null)
        } catch (e: CreateRendererException) {
            result.error("PDF_RENDER", "Can't create PDF renderer", null)
        }
    }

    private fun closeDocumentHandler(call: MethodCall, result: Result) {
        try {
            val id = call.arguments<String>()
            documents.close(id)
            result.success(null)
        } catch (e: NullPointerException) {
            result.error("PDF_RENDER", "Need call arguments: id!", null)
        } catch (e: RepositoryItemNotFoundException) {
            result.error("PDF_RENDER", "Document not exist in documents repository", null)
        }
    }

    private fun closePageHandler(call: MethodCall, result: Result) {
        try {
            val id = call.arguments<String>()
            pages.close(id)
            result.success(null)
        } catch (e: NullPointerException) {
            result.error("PDF_RENDER", "Need call arguments: id!", null)
        } catch (e: RepositoryItemNotFoundException) {
            result.error("PDF_RENDER", "Page not exist in pages repository", null)
        }
    }

    private fun openPageHandler(call: MethodCall, result: Result) {
        try {
            val documentId = call.argument<String>("documentId")!!
            val pageNumber  = call.argument<Int>("page")!!
            Thread {
                val pageRenderer = documents.get(documentId).openPage(pageNumber)
                result.success(pages.register(documentId, pageRenderer).infoMap)
            }.start()
        } catch (e: NullPointerException) {
            result.error("PDF_RENDER", "Need call arguments: documentId & page!", null)
        } catch (e: RepositoryItemNotFoundException) {
            result.error("PDF_RENDER", "Document not exist in documents", null)
        }
    }

    private fun renderHandler(call: MethodCall, result: Result) {
        try {
            val pageId = call.argument<String>("pageId")!!
            val width = call.argument<Int>("width")!!
            val height  = call.argument<Int>("height")!!
            val format = call.argument<Int>("format") ?: 0 //0 Bitmap.CompressFormat.JPEG
            val backgroundColor = call.argument<String>("backgroundColor")
            val color  = if (backgroundColor != null) Color.parseColor(backgroundColor) else Color.TRANSPARENT

            val page = pages.get(pageId)

            Thread {
                val results = page.render(width, height, color, format).toMap
                result.success(results)
            }.start()
        } catch (e: Exception) {
            result.error("PDF_RENDER", "Unexpected error", e)
        }
    }

    private fun openDataDocument(data: ByteArray): Pair<ParcelFileDescriptor, PdfRenderer>? {
        val tempDataFile = File(registrar.context().cacheDir, "$randomFilename.pdf")
        if (!tempDataFile.exists()) {
            tempDataFile.writeBytes(data)
        }
        Log.d("PDF_RENDER", "OpenDataDocument. Created file: " + tempDataFile.path)
        return openFileDocument(tempDataFile)
    }

    private fun openAssetDocument(assetPath: String): Pair<ParcelFileDescriptor, PdfRenderer>?{
        val fullAssetPath = registrar.lookupKeyForAsset(assetPath)
        val tempAssetFile = File(registrar.context().cacheDir, "$randomFilename.pdf")
        if (!tempAssetFile.exists()) {
            val inputStream = registrar.context().assets.open(fullAssetPath)
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

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "io.scer.pdf.renderer")
            channel.setMethodCallHandler(NativePDFRendererPlugin(registrar))
        }
    }
}

