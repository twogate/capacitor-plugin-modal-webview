package org.twogate.plugins.modalwebview

import android.graphics.Rect
import android.view.ViewGroup
import android.widget.FrameLayout
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin

@CapacitorPlugin(name = "ModalWebView")
class ModalWebViewPlugin : Plugin() {
    private lateinit var fragment: ModalWebViewFragment

    @PluginMethod
    fun open(call: PluginCall) {
        val rawOptions = call.getObject("options")
        if (rawOptions == null) {
            call.reject("options is undefined.")
            return
        }

        val options: ModalWebViewOptions = try {
            ModalWebViewOptions(rawOptions)
        } catch(exception: Exception) {
            call.reject(exception.message)
            return
        }

        val ret = JSObject()

        activity.runOnUiThread {
            val transaction = activity.supportFragmentManager.beginTransaction()
            val viewParent = FrameLayout(bridge.context)

            fragment = ModalWebViewFragment().newInstance(options)

            val rect = Rect()
            activity.window.decorView.getWindowVisibleDisplayFrame(rect)

            viewParent.layoutParams = ViewGroup.LayoutParams(rect.width(), rect.height())
            viewParent.id = R.id.modal_webview_parent_view

            (bridge.webView.parent as ViewGroup).addView(viewParent)

            transaction.setCustomAnimations(R.anim.show_modal, R.anim.dismiss_modal, R.anim.show_modal, R.anim.dismiss_modal)
            transaction.add(viewParent.id, fragment)
            transaction.commit()
        }

        call.resolve(ret)
    }
}
