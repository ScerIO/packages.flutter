package io.scer.pdfx.document

import android.annotation.TargetApi
import android.graphics.pdf.PdfRenderer
import android.os.Build
import android.os.ParcelFileDescriptor

@TargetApi(Build.VERSION_CODES.LOLLIPOP)
class Document (
    val id: String,
    private val documentRenderer: PdfRenderer,
    private val fileDescriptor: ParcelFileDescriptor
) {
    val pagesCount: Int get() = documentRenderer.pageCount

    val infoMap: Map<String, Any> get() =
        mapOf(
            "id" to id,
            "pagesCount" to pagesCount
        )

    fun close() {
        documentRenderer.close()
        fileDescriptor.close()
    }

    /**
     * Open page by page number (not index!)
     */
    fun openPage(pageNumber: Int): PdfRenderer.Page = documentRenderer.openPage(pageNumber - 1)
}
