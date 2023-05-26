import { WebPlugin } from '@capacitor/core';

import type { ModalWebViewOptions, ModalWebViewPlugin } from './definitions';

export class ModalWebViewWeb extends WebPlugin implements ModalWebViewPlugin {
  async open(options: { options: ModalWebViewOptions }): Promise<boolean> {
    console.log('OPEN', options)
    throw new Error('open() method not implemented on web.');
  }
}
