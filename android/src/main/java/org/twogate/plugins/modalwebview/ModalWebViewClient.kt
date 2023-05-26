package org.twogate.plugins.modalwebview

import android.graphics.Bitmap
import android.net.Uri
import android.webkit.CookieManager
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.launch


class ModalWebViewClient(options: ModalWebViewOptions) : WebViewClient() {
    val options: ModalWebViewOptions = options

    enum class Result {
        Success,
        Failure,
    }

    private val _pageLoadedStatus = MutableSharedFlow<Result>()
    val pageLoadedStatus = _pageLoadedStatus.asSharedFlow()

    override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
        if (options.enableCookie) {
            val cookieManager = CookieManager.getInstance()
            cookieManager.setAcceptCookie(true);
            cookieManager.setAcceptThirdPartyCookies(view, true);
            cookieManager.acceptCookie();
        }

        super.onPageStarted(view, url, favicon)
    }

    override fun onPageFinished(view: WebView?, url: String?) {
        super.onPageFinished(view, url)
        GlobalScope.launch {
            _pageLoadedStatus.emit(Result.Success)
        }
    }

    override fun onReceivedError(
        view: WebView?,
        request: WebResourceRequest?,
        error: WebResourceError?
    ) {
        super.onReceivedError(view, request, error)
        GlobalScope.launch {
            _pageLoadedStatus.emit(Result.Failure)
        }
    }

    override fun doUpdateVisitedHistory(view: WebView?, url: String?, isReload: Boolean) {
        val flushCookiePath = options.pathToFlushCookie
        if (flushCookiePath != null) {
            val mUri = Uri.parse(url)
            val path = mUri.path
            if (path == flushCookiePath) {
                val cookieManager = CookieManager.getInstance()
                cookieManager.flush()
            }
        }

        super.doUpdateVisitedHistory(view, url, isReload)
    }
}