package org.twogate.plugins.modalwebview

import android.content.Context
import android.util.AttributeSet
import android.view.KeyEvent
import android.view.View
import android.webkit.WebView
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.flow.SharedFlow


class ModalWebView: WebView {
    lateinit var pageLoadedStatus: SharedFlow<ModalWebViewClient.Result>
    fun reload(loaderView: View) {
        loaderView.visibility = View.VISIBLE
    }
    fun loadSucceed(loaderView: View) {
        loaderView.visibility = View.GONE
        visibility = View.VISIBLE
    }
    fun loadFailed(
        view: View,
        fragment: ModalWebViewFragment,
        loaderView:View,
        errorMessage: String = "Failed to load web page"
    ) {
        loaderView.visibility = View.GONE
        val snackbar = Snackbar
            .make(view, errorMessage, Snackbar.LENGTH_LONG)
            .setAction("OK") {
                fragment.activity.supportFragmentManager
                    .beginTransaction()
                    .setCustomAnimations(R.anim.dismiss_modal, R.anim.dismiss_modal)
                    .remove(fragment)
                    .commit()
            }
        snackbar.show()
    }

    fun initializeWebView(options: ModalWebViewOptions) {
        setInitialScale(1)
        settings.domStorageEnabled = true
        settings.javaScriptEnabled = true
        settings.useWideViewPort = true
        settings.loadWithOverviewMode = true

        val modalWebViewClient = ModalWebViewClient(options)
        pageLoadedStatus = modalWebViewClient.pageLoadedStatus
        webViewClient = modalWebViewClient

        setOnKeyListener { v, keyCode, event ->
            if (event.action === KeyEvent.ACTION_DOWN) {
                val webView = v as WebView
                when (keyCode) {
                    KeyEvent.KEYCODE_BACK -> if (webView.canGoBack()) {
                        webView.goBack()
                        return@setOnKeyListener true
                    }
                }
            }

            return@setOnKeyListener false
        }
    }

    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    )
}