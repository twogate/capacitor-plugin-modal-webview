import { registerPlugin } from '@capacitor/core';

import type { ModalWebViewPlugin } from './definitions';

const ModalWebView = registerPlugin<ModalWebViewPlugin>('ModalWebView', {
  web: () => import('./web').then(m => new m.ModalWebViewWeb()),
});

export * from './definitions';
export { ModalWebView };
