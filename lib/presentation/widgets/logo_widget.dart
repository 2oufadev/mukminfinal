import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:video_player/video_player.dart';

class Logo extends StatefulWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  VideoPlayerController? _controller;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(ImageResource.welcomeAnimation);
  }

  Future<bool> started() async {
    await _controller!.initialize();

    chewieController = ChewieController(
        videoPlayerController: _controller!,
        autoPlay: true,
        looping: false,
        showControls: false);

    return true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // _controller.dispose();
    // chewieController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset('assets/animation/Islam.gif',
            width: double.infinity, height: double.infinity)
        // FutureBuilder<bool>(
        //     future: started(),
        //     builder: (context, AsyncSnapshot<bool> snapshot) {
        //       if (snapshot.data == true) {
        //         return Container(
        //             color: Colors.white,
        //             child: Chewie(controller: chewieController));
        //       } else {
        //         return Container();
        //       }
        //     }),
      ],
    );
  }
}
