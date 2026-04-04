import 'dart:html' as html;

void redirectToUrl(String url) {
  html.window.location.href = url;
}

void saveToStorage(String key, String value) {
  html.window.localStorage[key] = value;
}

String? readFromStorage(String key) {
  return html.window.localStorage[key];
}

void removeFromStorage(String key) {
  html.window.localStorage.remove(key);
}
