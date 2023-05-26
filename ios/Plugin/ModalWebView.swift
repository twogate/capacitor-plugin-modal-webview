import Foundation
import UIKit
import WebKit

@objc public class ModalWebView: UIViewController {
    private let INDICATOR_VIEW_TAG = 101
    private let TOOL_BAR_HEIGHT = 40.0
    private let COLOR_TOOL_BAR_FOREGROUND = UIColor(named: "ToolBarForeground")
    private let COLOR_TOOL_BAR_BACKGROUND = UIColor(named: "ToolBarBackground")
    private let COLOR_BASE_BACKGROUND = UIColor(named: "BaseBackground")

    private var webView: WKWebView!
    private var failedView: UIView? = nil
    private var firstViewIndicator: UIActivityIndicatorView!
    private var progressBarView: UIProgressView!
    
    private var navController: UINavigationController!

    private var toolBarContainerView: UIView!
    private var toolBar: UIToolbar!
    private var toolBarIsHidden = false
    
    private var rewindButton: UIBarButtonItem!
    private var fastForwardButton: UIBarButtonItem!
    private var refreshButton: UIBarButtonItem!
    
    var lastOffsetY: CGFloat = 0
    
    var isWebViewLoad: Bool = false
    
    private var options: ModalWebviewOptions!
    
    public func presentModal(rootViewController: UIViewController) {
        navController = UINavigationController(rootViewController: self)
        navController.isModalInPresentation = true
    
        rootViewController.present(navController, animated: true)
    }
    
    @objc func handleClose(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    @objc func handleForward(sender: UIBarButtonItem) {
        webView.goForward()
    }
    @objc func handleBack(sender: UIBarButtonItem) {
        webView.goBack()
    }
    @objc func handleReload(sender: UIBarButtonItem) {
        webView.reload()
    }
    
    @objc func retryFailedView(sender: UIButton!) {
        failedView?.removeFromSuperview()
        setWebView()
    }
    
    func createIndicator() -> UIActivityIndicatorView {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.backgroundColor = .systemBackground
        indicatorView.tag = INDICATOR_VIEW_TAG
        return indicatorView
    }
    func showIndicator() {
        if (self.isWebViewLoad) {
            return
        }
        
        firstViewIndicator.frame = view.frame
        firstViewIndicator.center = view.center
        view.addSubview(firstViewIndicator)
        firstViewIndicator.startAnimating()
    }
    
    func createToolBar(frame: CGRect, position: CGPoint) -> UIToolbar {
        let _toolBar = UIToolbar();
        _toolBar.frame = frame
        _toolBar.isTranslucent = false
        _toolBar.backgroundColor = COLOR_TOOL_BAR_BACKGROUND
        _toolBar.barTintColor = COLOR_TOOL_BAR_BACKGROUND
        _toolBar.tintColor = COLOR_TOOL_BAR_FOREGROUND
        
        let spacerEdge: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacerEdge.width = 16
        let spacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 42
        
        rewindButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem(rawValue: 101)!, target: self, action: #selector(handleBack(sender:)))
        rewindButton.isEnabled = false
        fastForwardButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem(rawValue: 102)!, target: self, action: #selector(handleForward(sender:)))
        fastForwardButton.isEnabled = false
        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(handleReload(sender:)))
        refreshButton.isEnabled = false
        let spacerRight: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        _toolBar.items = [spacerEdge, rewindButton, spacer, fastForwardButton, spacerRight, refreshButton, spacerEdge]
        
        return _toolBar
    }
    func setToolBar() {
        let width:CGFloat = view.frame.size.width
        let height:CGFloat = view.frame.size.height
        let window = UIApplication.shared.windows.first
        let toolBarHeight = TOOL_BAR_HEIGHT
        let bottomSafeArea = CGFloat(window?.safeAreaInsets.bottom ?? 0)
        toolBar = createToolBar(
            frame: CGRect(x: 0, y: 0, width: width, height: toolBarHeight),
            position: CGPoint(x: width / 2, y: height - ((toolBarHeight + bottomSafeArea) / 2))
        )
        toolBarContainerView = UIView(frame: CGRect(x: 0, y: height - (toolBarHeight + bottomSafeArea), width: width, height: toolBarHeight + bottomSafeArea))
        
        toolBarContainerView.backgroundColor = COLOR_TOOL_BAR_BACKGROUND
 
        
        toolBarContainerView.addSubview(toolBar)
        view.addSubview(toolBarContainerView)
    }
    func setNavigationItem() {
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self,action: #selector(handleClose(sender:)))
        closeButton.tintColor = COLOR_TOOL_BAR_FOREGROUND
        self.navController.navigationBar.backgroundColor = COLOR_TOOL_BAR_BACKGROUND
 
        self.navController.navigationBar.barTintColor = COLOR_TOOL_BAR_BACKGROUND
        
        progressBarView = UIProgressView(frame: CGRect(
            x: 0,
            y: self.navController.navigationBar.frame.height - 0.5,
            width: self.navController.navigationBar.frame.width,
            height: 1)
        )
        progressBarView.transform = CGAffineTransformScale(progressBarView.transform, 1, 0.5)
        progressBarView.tintColor = COLOR_TOOL_BAR_FOREGROUND
        progressBarView.backgroundColor = COLOR_TOOL_BAR_BACKGROUND
        self.navController.navigationBar.addSubview(progressBarView)
        self.navigationItem.setRightBarButton(closeButton, animated: false)
    }
    func setContentView() {
        let contentView = UIView(frame: view.frame)
        contentView.backgroundColor = COLOR_BASE_BACKGROUND
        view = contentView
    }
    func setWebView() {
        let toolBarHeight = TOOL_BAR_HEIGHT
        let window = UIApplication.shared.windows.first
        let bottomSafeArea = CGFloat(window?.safeAreaInsets.bottom ?? 0)
        let bottomPadding = bottomSafeArea
        
        view.addSubview(webView)
        webView.frame = view.frame.inset(by: UIEdgeInsets(top: 0.0, left: 0.0, bottom: toolBarHeight + bottomPadding, right: 0.0))
        showIndicator()
    }
    func setFailedToLoadView() {
        let parentFrame = view.frame
        
        failedView = UIView(frame: CGRect(x: 0, y: self.navController.navigationBar.frame.height + 20, width: parentFrame.width, height: parentFrame.height))
        failedView!.backgroundColor = COLOR_BASE_BACKGROUND
        
        let networkErrorIconConfiguration = UIImage.SymbolConfiguration(pointSize: 108.0)
        let networkErrorIcon = UIImage(systemName: "wifi.exclamationmark", withConfiguration: networkErrorIconConfiguration)
        let networkErrorIconView = UIImageView(image: networkErrorIcon)
        networkErrorIconView.contentMode = .scaleAspectFit
        networkErrorIconView.tintColor = .black
        networkErrorIconView.frame.origin.x = (failedView!.frame.width - networkErrorIcon!.size.width) / 2
        
        let textView = UITextView()
        textView.text = options.loadingWebPageErrorMessage
        textView.backgroundColor = failedView!.backgroundColor
        textView.textAlignment = .center
        textView.font = .systemFont(ofSize: 24.0)
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame = CGRect(x:0, y: networkErrorIconView.frame.height, width: parentFrame.width, height: newSize.height)

        let retryButton = UIButton(type: UIButton.ButtonType.system)
        retryButton.setTitle("Retry", for: .normal)
        retryButton.tintColor = COLOR_TOOL_BAR_FOREGROUND
        retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        retryButton.frame = CGRect(
            x: (parentFrame.width - newSize.width) / 2,
            y: networkErrorIconView.frame.height + textView.frame.height,
            width: newSize.width,
            height: newSize.height
        )
        retryButton.addTarget(self, action: #selector(retryFailedView), for: .touchUpInside)
        
        failedView!.addSubview(networkErrorIconView)
        failedView!.addSubview(textView)
        failedView!.addSubview(retryButton)
        
        webView.removeFromSuperview()
        
        view.addSubview(failedView!)
    }
    
    func storeCookie() {
        if (!options.enableCookie) {
            return
        }
        
        guard let cookies = HTTPCookieStorage.shared.cookies else { return }
        var cookieDictionary = [String: AnyObject]()
        for cookie in cookies {
            cookieDictionary[cookie.name] = cookie.properties as AnyObject?
        }
        UserDefaults.standard.set(cookieDictionary, forKey: "cookie")
    }
    private func retrieveCookies() {
        if (!options.enableCookie) {
            return
        }
        
        guard let cookieDictionary = UserDefaults.standard.dictionary(forKey: "cookie") else { return }
        for (_, cookieProperties) in cookieDictionary {
            if let cookieProperties = cookieProperties as? [HTTPCookiePropertyKey : Any] {
                if let cookie = HTTPCookie(properties: cookieProperties ) {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            }
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    convenience init(options: ModalWebviewOptions) {
        self.init(nibName:nil, bundle:nil)
        self.webView = createWebView()
        self.firstViewIndicator = createIndicator()
        self.options = options
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setContentView()
        setWebView()
        setNavigationItem()
        setToolBar()
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view = webView
        
        retrieveCookies()
        
        let url = URL(string:options.url)
        let request = URLRequest(url: url!)
    
        webView.load(request)
        
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);
    }
}
extension ModalWebView: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffsetY = scrollView.contentOffset.y
    }
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let hide = scrollView.contentOffset.y > self.lastOffsetY
        
        if (toolBarIsHidden != hide) {
            toolBarIsHidden = hide
            UIView.animate(withDuration: 0.15, animations: {
                let viewHeight = self.view.frame.height
                let viewWidth = self.view.frame.width
                
                self.toolBarContainerView.layer.frame = CGRect(x: 0, y: viewHeight - (hide ? 0 : 74.0), width: viewWidth, height: hide ? 0.0 : 74.0)
                self.webView.frame = self.view.frame.inset(by: UIEdgeInsets(top: 0.0, left: 0.0, bottom: hide ? 0 : 74, right: 0.0))
            })
        }
    }
}

extension ModalWebView: WKUIDelegate, WKNavigationDelegate {
    func createWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.delegate = self
        return webView
    }
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        firstViewIndicator.removeFromSuperview()
        isWebViewLoad = true
        rewindButton.isEnabled = webView.canGoBack
        fastForwardButton.isEnabled = webView.canGoForward
        refreshButton.isEnabled = true
    }
    public func webViewDidClose(_ webView: WKWebView) {
        storeCookie()
    }
    public func webView(_: WKWebView, didStartProvisionalNavigation: WKNavigation!) {
        progressBarView.layer.sublayers?.forEach { $0.removeAllAnimations() }
        progressBarView.setProgress(0.01, animated: false)
        progressBarView.tintColor = COLOR_TOOL_BAR_FOREGROUND
    }
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            if  let url = navigationAction.request.url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        return nil
    }
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            UIView.animate(
                withDuration: 0.15,
                animations: {
                    self.progressBarView.setProgress(Float(self.webView.estimatedProgress), animated: true)
                },
                completion: { finished in
                    if (finished) {
                        if (self.webView.estimatedProgress >= 1.0) {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15) {
                                self.progressBarView.tintColor = self.COLOR_TOOL_BAR_BACKGROUND
                            }
                        }
                    }
                }
            )
        }
    }
    public func webView(_: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) {
        setFailedToLoadView()
    }
}


