import { Component } from '@angular/core';
import { ModalWebView, ModalWebViewOptions } from '@twogate/capacitor-modal-webview';

@Component({
  selector: 'app-tab1',
  templateUrl: 'tab1.page.html',
  styleUrls: ['tab1.page.scss']
})
export class Tab1Page {

  constructor() {}

  openModal() {
    const options:  ModalWebViewOptions = {
      url: 'https://twogate.com',
      loadWebPageErrorMessage: 'Failed to load web page',
    }
    ModalWebView.open({ options });
  }
}
