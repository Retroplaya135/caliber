// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

Future<bool> postFunnelEvent(Uri endpoint, Map<String, Object?> payload) async {
  try {
    final response = await html.HttpRequest.request(
      endpoint.toString(),
      method: 'POST',
      requestHeaders: const <String, String>{
        'accept': 'application/json',
        'content-type': 'application/json',
      },
      sendData: jsonEncode(payload),
    ).timeout(const Duration(seconds: 5));
    final status = response.status;
    return status != null && status >= 200 && status < 300;
  } on Object {
    return false;
  }
}
