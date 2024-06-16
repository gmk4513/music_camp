import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubeVideoPage extends StatefulWidget {
  final String videoUrl;

  YouTubeVideoPage({required this.videoUrl});

  @override
  _YouTubeVideoPageState createState() => _YouTubeVideoPageState();
}

class _YouTubeVideoPageState extends State<YouTubeVideoPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl)!;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      params: YoutubePlayerParams(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Video'),
      ),
      body: YoutubePlayerIFrame(
        controller: _controller,
        aspectRatio: 16 / 9,
      ),
    );
  }
}



//youtube_player_flutter 사용
/*import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeVideoPage extends StatefulWidget {
  final String videoUrl;

  YouTubeVideoPage({required this.videoUrl});

  @override
  _YouTubeVideoPageState createState() => _YouTubeVideoPageState();
}

class _YouTubeVideoPageState extends State<YouTubeVideoPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Video'),
      ),
      body: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        onReady: () {
          print('Player is ready.');
        },
      ),
    );
  }
}*/