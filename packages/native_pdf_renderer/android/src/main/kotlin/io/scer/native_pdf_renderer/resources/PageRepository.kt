package io.scer.native_pdf_renderer.resources

import android.annotation.TargetApi
import android.graphics.pdf.PdfRenderer
import android.os.Build
import io.scer.native_pdf_renderer.document.Page
import io.scer.native_pdf_renderer.utils.randomID

@TargetApi(Build.VERSION_CODES.LOLLIPOP)
class PageRepository : Repository<Page>() {
    /**
     * Register page in repository
     * @returns page id
     */
    fun register(documentId: String, pageRenderer: PdfRenderer.Page): Page {
        val id = randomID
        val page = Page(id, documentId, pageRenderer)
        set(id, page)
        return page
    }

    public override fun close(id: String) {
        get(id).close()
        super.close(id)
    }
}