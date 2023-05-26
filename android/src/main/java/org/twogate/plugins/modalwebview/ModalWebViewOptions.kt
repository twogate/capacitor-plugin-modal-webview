package org.twogate.plugins.modalwebview

import com.getcapacitor.JSObject

class ModalWebViewOptions(options: JSObject) {
    val url: String = options.getString("url") ?: throw Exception("options.url is undefined")
    val loadWebPageErrorMessage = options.getString("loadWebPageErrorMessage") ?: throw Exception("options.loadWebPageErrorMessage is undefined")
    val enableCookie = options.getBool("enableCookie") ?: false
    val pathToFlushCookie = options.getString("enableCookie")
}