import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewWidget extends StatefulWidget {
  final String videoPath;
  final BoxFit fit;
  final bool muted;

  const VideoPreviewWidget({
    super.key,
    required this.videoPath,
    this.fit = BoxFit.cover,
    this.muted = true,
  });

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant VideoPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath) {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    // Clean up previous controller if any
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      setState(() {
        _isInitialized = false;
        _hasError = false;
      });
    }

    try {
      final path = widget.videoPath;
      if (path.startsWith('http') || path.startsWith('https')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(path));
      } else {
        _controller = VideoPlayerController.file(File(path));
      }

      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
        _controller!.setLooping(true);
        if (widget.muted) {
          _controller!.setVolume(0.0);
        } else {
          _controller!.setVolume(1.0);
        }
        _controller!.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: const Color(0xFF1E2022),
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white30, size: 32),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE2B744)),
          ),
        ),
      );
    }

    return FittedBox(
      fit: widget.fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}
