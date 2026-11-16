// This file is selected only by the conditional web import in DatabaseService.
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

const _storageKey = 'taskforge.data.v1';

String? read() => html.window.localStorage[_storageKey];

Future<void> write(String value) async {
  html.window.localStorage[_storageKey] = value;
}
