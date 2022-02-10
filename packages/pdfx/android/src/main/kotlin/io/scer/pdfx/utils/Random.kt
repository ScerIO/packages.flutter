package io.scer.pdfx.utils

import java.util.UUID.randomUUID

val randomID get(): String = randomUUID().toString()

val randomFilename get(): String = randomID.replace("-".toRegex(), "")
