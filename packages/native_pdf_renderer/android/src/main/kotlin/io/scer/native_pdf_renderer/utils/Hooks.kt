package io.scer.native_pdf_renderer.utils

import android.graphics.Bitmap
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.InputStream

fun InputStream.toFile(file: File) {
    file.outputStream().use { this.copyTo(it) }
}

/**
 * Save bitmap to file
 */
fun Bitmap.toFile(file: File): File {
    val stream = file.outputStream()
    this.compress(Bitmap.CompressFormat.PNG, 100, stream)
    stream.flush()
    stream.close()
    return file
}

/**
 * Convert bitmap to byte array using ByteBuffer.
 */
fun Bitmap.toByteArray(format: Int): ByteArray {
    val stream = ByteArrayOutputStream()
    val compressFormat: Bitmap.CompressFormat = when(format) {
        0 -> Bitmap.CompressFormat.JPEG
        1 -> Bitmap.CompressFormat.PNG
        2 -> Bitmap.CompressFormat.WEBP
        else -> Bitmap.CompressFormat.JPEG
    }

    this.compress(compressFormat, 100, stream)
    return stream.toByteArray()
}