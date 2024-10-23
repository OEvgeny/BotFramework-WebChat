import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import * as WebChat from 'botframework-webchat';

window.WebChat = WebChat;

const init = async () => {
  const { WebChat } = window;

  if (!WebChat.loadCustomization && !WebChat.renderCheatSheet) {
    setTimeout(init, 100);

    return;
  }

  await WebChat.loadCustomization();
  await WebChat.renderCheatSheet();

  ReactDOM.render(<App />, document.getElementsByTagName('main')[0]);
};

init();
