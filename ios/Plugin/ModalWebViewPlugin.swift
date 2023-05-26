import Foundation
import Capacitor

public struct ModalWebviewOptions {
    let url: String
    let loadingWebPageErrorMessage: String
    let enableCookie: Bool
}

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(ModalWebViewPlugin)
public class ModalWebViewPlugin: CAPPlugin {
    func modalWebViewOptions(call: CAPPluginCall) -> ModalWebviewOptions? {
        guard let options = call.getObject("options") else {
            call.reject("[ModalWebView] optinos is undefined.")
            return nil
        }
        guard let url = options["url"] as! String? else {
            call.reject("[ModalWebView] optinos.url is required.")
            return nil
        }
        
        guard let loadingWebPageErrorMessage = options["loadWebPageErrorMessage"] as! String? else {
            call.reject("[ModalWebView] optinos.loadWebPageErrorMessage is required.")
            return nil
        }
        
        let enableCookie = options["enableCookie"] as! Bool? ?? false

        return ModalWebviewOptions(
            url: url,
            loadingWebPageErrorMessage: loadingWebPageErrorMessage,
            enableCookie: enableCookie
        )
    }
    @objc func open(_ call:CAPPluginCall) {
        guard let options = modalWebViewOptions(call: call) else {
            call.reject("Failed to initialize options")
            return
        }

        guard let capViewController = self.bridge?.viewController else {
           call.reject("capacitor webview is null")
           return
        }
        
        DispatchQueue.main.async {
            let modalWebView = ModalWebView(options: options)
        
            modalWebView.presentModal(rootViewController: capViewController)
        
            call.resolve([
                "opened": true
            ])
        }
    }
}
