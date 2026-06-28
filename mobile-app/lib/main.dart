import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lyenk Mail',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WebmailScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WebmailScreen extends StatefulWidget {
  const WebmailScreen({super.key});

  @override
  State<WebmailScreen> createState() => _WebmailScreenState();
}

class _WebmailScreenState extends State<WebmailScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);
            
            // Allow navigation to the mail server
            if (uri.host.contains('mail.lyenk.com')) {
              // But check if it's a file download typically ending with a file extension
              // If it's a clear file download, we could route it out, but SOGo usually handles this dynamically.
              return NavigationDecision.navigate;
            }

            // For external links, open in the native browser
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            
            // Prevent the webview from navigating to the external link
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://mail.lyenk.com'));
  }

  Future<void> _handleRefresh() async {
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We add an AppBar with a refresh button as a fallback since native Pull-To-Refresh
      // doesn't reliably trigger through a platform WebView widget on all devices.
      appBar: AppBar(
        title: const Text('LYENK Mail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
