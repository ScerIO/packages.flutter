package io.scer.pdf.renderer.utils

import java.util.UUID.randomUUID

val randomID get() = randomUUID().toString()

val randomFilename get() = randomID.replace("-".toRegex(), "")