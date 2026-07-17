import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

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
  late final VideoPlayerController _videoController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _videoController = VideoPlayerController.asset('assets/app_icon_anim/app_icon_anim.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {}); // Ensure the first frame is shown
      });
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);
            
            if (uri.host.contains('mail.lyenk.com')) {
              return NavigationDecision.navigate;
            }

            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            
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
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _handleRefresh,
              child: WebViewWidget(controller: _controller),
            ),
            if (_isLoading)
              Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: _videoController.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController.value.aspectRatio,
                          child: VideoPlayer(_videoController),
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
