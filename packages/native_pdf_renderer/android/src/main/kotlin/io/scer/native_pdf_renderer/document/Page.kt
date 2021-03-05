package io.scer.native_pdf_renderer.document

import android.annotation.TargetApi
import android.graphics.Bitmap
import android.graphics.pdf.PdfRenderer
import android.os.Build
import io.scer.native_pdf_renderer.utils.toByteArray

@TargetApi(Build.VERSION_CODES.LOLLIPOP)
class Page (
        private val id: String,
        private val documentId: String,
        private val pageRenderer: PdfRenderer.Page
) {
    /** Page number in document */
    private val number: Int get() = pageRenderer.index

    private val width: Int get() = pageRenderer.width
    private val height: Int get() = pageRenderer.height

    val infoMap: Map<String, Any> get() =
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

    fun render(width: Int, height: Int, background: Int, format: Int, crop: Boolean, cropX: Int, cropY: Int, cropW: Int, cropH: Int): Data {
        val bitmap = Bitmap.createBitmap(
                width,
                height,
                Bitmap.Config.ARGB_8888)
        bitmap.eraseColor(background)

        pageRenderer.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)

        if (crop && (cropW != width || cropH != height)){
            val cropped = Bitmap.createBitmap(bitmap, cropX, cropY, cropW, cropH)
            return Data(
                cropW,
                cropH,
                data = cropped.toByteArray(format)
            )
        } else {
            return Data(
                width,
                height,
                data = bitmap.toByteArray(format)
            )
        }
    }

    data class Data(
            val width: Int,
            val height: Int,
            val data: ByteArray
    ) {
        val toMap: Map<String, Any> get() =
            mapOf(
                    "width" to width,
                    "height" to height,
                    "data" to data
            )

        override fun equals(other: Any?): Boolean {
            if (this === other) return true
            if (javaClass != other?.javaClass) return false

            other as Data

            if (!data.contentEquals(other.data)) return false

            return true
        }

        override fun hashCode(): Int = data.contentHashCode()
    }
}
