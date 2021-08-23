package io.scer.native_pdf_renderer.resources

import java.lang.Exception

class RepositoryItemNotFoundException(message: String): Exception(message)

abstract class Repository<T> {
    private val items: MutableMap<String, T> = HashMap()

    @Throws(RepositoryItemNotFoundException::class)
    fun get(id: String): T {
        if (!exist(id)) throw RepositoryItemNotFoundException(id)
        return items[id]!!
    }

    fun set(id: String, item: T) {
        items[id] = item
    }

    private fun exist(id: String): Boolean = items.contains(id)

    protected open fun close(id: String) {
        items.remove(id)
    }
}