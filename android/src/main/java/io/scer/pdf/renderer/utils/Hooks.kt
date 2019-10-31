package io.scer.pdf.renderer.utils

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
fun Bitmap.toByteArray(): ByteArray {
    val stream = ByteArrayOutputStream()
    this.compress(Bitmap.CompressFormat.PNG, 100, stream)
    return stream.toByteArray()
}