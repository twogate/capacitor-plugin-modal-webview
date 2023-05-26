package org.twogate.plugins.modalwebview

import android.content.res.ColorStateList
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.widget.ProgressBar
import androidx.core.content.ContextCompat


class ModalWebViewChromeClient(progressBar: ProgressBar) : WebChromeClient() {
    val progressBar: ProgressBar = progressBar

    override fun onProgressChanged(view: WebView?, newProgress: Int) {
        super.onProgressChanged(view, newProgress)

        if (view != null) {
            val toolbarBackgroundColor = ContextCompat.getColor(view.context, R.color.colorModalWebViewToolBarBackgroundColor)
            val toolbarForegroundColor = ContextCompat.getColor(view.context, R.color.colorModalWebViewToolBarForegroundColor)
            val baseBackgroundColor = ContextCompat.getColor(view.context, R.color.colorModalWebViewBaseBackgroundColor)

            progressBar.progress = view.progress

            if (view.progress >= 100) {
                progressBar.progressTintList = ColorStateList.valueOf(toolbarBackgroundColor)
                progressBar.progressBackgroundTintList = ColorStateList.valueOf(toolbarBackgroundColor)
            } else {
                progressBar.progressBackgroundTintList = ColorStateList.valueOf(baseBackgroundColor)
                progressBar.progressTintList = ColorStateList.valueOf(toolbarForegroundColor)
            }
        }
    }
}