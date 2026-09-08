package io.scer.pdfx.document

import android.annotation.TargetApi
import android.graphics.Bitmap
import android.graphics.Matrix
import android.graphics.pdf.PdfRenderer
import android.os.Build
import io.scer.pdfx.utils.toFile
import java.io.File

@TargetApi(Build.VERSION_CODES.LOLLIPOP)
class Page(
    val id: String,
    private val documentId: String,
    val pageRenderer: PdfRenderer.Page
    ) {
    /** Page number in document */
    private val number: Int get() = pageRenderer.index

    val width: Int get() = pageRenderer.width
    val height: Int get() = pageRenderer.height

    val infoMap: Map<String, Any>
        get() =
            mapOf(
                "documentId" to documentId,
                "id" to id,
                "pageNumber" to number,
                "width" to width,
                "height" to height
            )

    fun close() {
        pageRenderer.close()
    }

    fun render(file: File, width: Int, height: Int, background: Int, format: Int, crop: Boolean, cropX: Int, cropY: Int, cropW: Int, cropH: Int, quality: Int, forPrint: Boolean): Data {
        val cropped = crop && (cropW != width || cropH != height)
        val outWidth = if (cropped) cropW else width
        val outHeight = if (cropped) cropH else height

        val bitmap = Bitmap.createBitmap(
            outWidth,
            outHeight,
            Bitmap.Config.ARGB_8888)
        bitmap.eraseColor(background)

        // Render straight into a bitmap the size of the requested region instead of
        // rasterizing the whole page and cropping afterwards: the transform scales the
        // page onto a `width` x `height` raster and then shifts it so that the crop
        // origin lands on (0, 0) of the destination bitmap. Output is identical, but
        // peak memory follows the region rather than the full page, which matters when
        // callers zoom in (a small region of a heavily scaled page is cheap, whereas
        // the full page at the same scale can be hundreds of megabytes).
        // This mirrors what the Windows backend already does in `Page::render`.
        val transform = if (cropped) {
            Matrix().apply {
                setValues(
                    floatArrayOf(
                        width.toFloat() / pageRenderer.width, 0f, -cropX.toFloat(),
                        0f, height.toFloat() / pageRenderer.height, -cropY.toFloat(),
                        0f, 0f, 1f
                    )
                )
            }
        } else {
            null
        }

        val mode = if (forPrint) PdfRenderer.Page.RENDER_MODE_FOR_PRINT else PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY
        pageRenderer.render(bitmap, null, transform, mode)

        bitmap.toFile(file, format, quality)
        return Data(
            outWidth,
            outHeight,
            file.absolutePath
        )
    }

    data class Data(
        val width: Int,
        val height: Int,
        val path: String
    ) {
        val toMap: Map<String, Any>
            get() =
                mapOf(
                    "width" to width,
                    "height" to height,
                    "path" to path
                )

        override fun equals(other: Any?): Boolean {
            if (this === other) return true
            if (javaClass != other?.javaClass) return false

            other as Data

            if (!path.contentEquals(other.path)) return false

            return true
        }

        override fun hashCode(): Int = width.hashCode()
            .times(31).plus(height.hashCode())
            .times(31).plus(path.hashCode())
    }
}
