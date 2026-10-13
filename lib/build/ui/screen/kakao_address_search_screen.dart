import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 카카오 우편번호 검색. 키 없이 도로명 주소를 고른다.
class KakaoAddressSearchScreen extends StatefulWidget {
  const KakaoAddressSearchScreen({super.key});

  @override
  State<KakaoAddressSearchScreen> createState() => _KakaoAddressSearchScreenState();
}

class _KakaoAddressSearchScreenState extends State<KakaoAddressSearchScreen> {
  late final WebViewController _controller;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..addJavaScriptChannel(
        'AddressChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final Object? decoded = jsonDecode(message.message);
          if (decoded is! Map) return;
          final String road = '${decoded['roadAddress'] ?? ''}'.trim();
          final String jibun = '${decoded['jibunAddress'] ?? ''}'.trim();
          final String address = road.isNotEmpty ? road : jibun;
          if (address.isEmpty || !mounted) return;
          Navigator.of(context).pop(address);
        },
      )
      ..loadHtmlString(_postcodeHtml, baseUrl: 'https://postcode.map.kakao.com');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(title: const Text('주소 검색')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

const String _postcodeHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
  <style>
    html, body, #wrap { margin: 0; padding: 0; width: 100%; height: 100%; }
  </style>
  <script src="https://t1.kakaocdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
</head>
<body>
  <div id="wrap"></div>
  <script>
    new kakao.Postcode({
      oncomplete: function(data) {
        AddressChannel.postMessage(JSON.stringify({
          roadAddress: data.roadAddress || '',
          jibunAddress: data.jibunAddress || ''
        }));
      },
      width: '100%',
      height: '100%'
    }).embed(document.getElementById('wrap'));
  </script>
</body>
</html>
''';
