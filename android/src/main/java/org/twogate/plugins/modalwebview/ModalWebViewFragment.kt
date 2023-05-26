package org.twogate.plugins.modalwebview

import android.content.Context
import android.graphics.Rect
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ProgressBar
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import com.google.android.material.appbar.MaterialToolbar
import com.google.android.material.progressindicator.CircularProgressIndicator
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch


class ModalWebViewFragment: Fragment {

    val activity: AppCompatActivity
    private val options: ModalWebViewOptions
    private val context: Context

    private fun setNavigationBarActions(view: View) {
        val toolbar = view.findViewById<MaterialToolbar>(R.id.modal_webview_toolbar)

        toolbar.setOnMenuItemClickListener {
            when(it.itemId) {
                R.id.menu_close -> {
                    activity.supportFragmentManager
                        .beginTransaction()
                        .setCustomAnimations(R.anim.dismiss_modal, R.anim.dismiss_modal)
                        .remove(this@ModalWebViewFragment)
                        .commit()
                }
            }
            return@setOnMenuItemClickListener true
        }
    }
    private fun initializeWebView(view: View) {
        val webView = view.findViewById<ModalWebView>(R.id.custom_webview)
        val loader = view.findViewById<CircularProgressIndicator>(R.id.modal_webview_loader)

        val progressBar = view.findViewById<ProgressBar>(R.id.modal_webview_progress_bar)

        web
        webView.webChromeClient = ModalWebViewChromeClient(progressBar)
        webView.loadUrl(options.url)

        val metrics = context.resources.displayMetrics
        val rect = Rect()
        activity.window.decorView.getWindowVisibleDisplayFrame(rect)
        webView.layoutParams.height = (rect.height() - (42 * metrics.density)).toInt()

        GlobalScope.launch {
            webView.pageLoadedStatus.collect() {
                when (it) {
                    ModalWebViewClient.Result.Success -> {
                        activity.runOnUiThread {
                            webView.loadSucceed(loader)
                        }
                    }

                    ModalWebViewClient.Result.Failure -> {
                        activity.runOnUiThread {
                            webView?.loadFailed(view, this@ModalWebViewFragment, loader, options.loadWebPageErrorMessage)
                        }
                    }
                }
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initializeWebView(view)
    }
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.modal_webview_fragment, container, false);
        setNavigationBarActions(view)

        return view
    }

    constructor(options: ModalWebViewOptions, activity: AppCompatActivity, context: Context) : super(R.layout.modal_webview_fragment) {
        this.activity = activity
        this.options = options
        this.context = context
    }
}