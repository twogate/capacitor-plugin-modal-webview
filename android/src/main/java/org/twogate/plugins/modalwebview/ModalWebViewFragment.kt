package org.twogate.plugins.modalwebview

import android.graphics.Rect
import android.os.Build
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ProgressBar
import androidx.fragment.app.Fragment
import com.google.android.material.appbar.MaterialToolbar
import com.google.android.material.progressindicator.CircularProgressIndicator
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch


class ModalWebViewFragment: Fragment() {
    private fun getOptions(): ModalWebViewOptions {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            arguments?.getSerializable("options", ModalWebViewOptions::class.java)!!
        } else {
            arguments?.getSerializable("options") as ModalWebViewOptions
        }
    }

    private fun setNavigationBarActions(view: View) {
        val toolbar = view.findViewById<MaterialToolbar>(R.id.modal_webview_toolbar)

        toolbar.setOnMenuItemClickListener {
            when(it.itemId) {
                R.id.menu_close -> {
                    requireActivity().supportFragmentManager
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
        val options = getOptions()
        val webView = view.findViewById<ModalWebView>(R.id.modal_webivew)
        webView.initializeWebView(options)

        val loader = view.findViewById<CircularProgressIndicator>(R.id.modal_webview_loader)
        val progressBar = view.findViewById<ProgressBar>(R.id.modal_webview_progress_bar)

        webView.webChromeClient = ModalWebViewChromeClient(progressBar)
        webView.loadUrl(options.url)

        val metrics = requireContext().resources.displayMetrics
        val rect = Rect()
        requireActivity().window.decorView.getWindowVisibleDisplayFrame(rect)
        webView.layoutParams.height = (rect.height() - (42 * metrics.density)).toInt()

        GlobalScope.launch {
            webView.pageLoadedStatus.collect() {
                when (it) {
                    ModalWebViewClient.Result.Success -> {
                        requireActivity().runOnUiThread {
                            webView.loadSucceed(loader)
                        }
                    }

                    ModalWebViewClient.Result.Failure -> {
                        requireActivity().runOnUiThread {
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

    public fun newInstance(options: ModalWebViewOptions): ModalWebViewFragment {
        val args = Bundle()

        val fragment = ModalWebViewFragment()
        args.putSerializable("options", options)
        fragment.arguments = args
        return fragment
    }
}