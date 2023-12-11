package org.twogate.plugins.modalwebview

import com.getcapacitor.JSObject
import java.io.Serializable

class ModalWebViewOptions(options: JSObject): Serializable {
    val url: String = options.getString("url") ?: throw Exception("options.url is undefined")
    val loadWebPageErrorMessage = options.getString("loadWebPageErrorMessage") ?: throw Exception("options.loadWebPageErrorMessage is undefined")
    val enableCookie = options.getBool("enableCookie") ?: false
    val pathToFlushCookie = options.getString("enableCookie")
}