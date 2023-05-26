/**
 *
 */
export interface ModalWebViewOptions {
  url: string;
  /*
  * Message to show when web page is failed to load.
  */
  loadWebPageErrorMessage: string;
  /**
   * If true, cookie in the webview will be stored even if you kill application.
   */
  enableCookie?: boolean;

  /**
   * only Android.
   * Path, cookie in the webview will be removed when webview load this path page.
   */
  pathToFlushCookie?: string;
}
export interface ModalWebViewPlugin {
  open(options: { options: ModalWebViewOptions }): Promise<boolean>;
}
