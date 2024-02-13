import 'package:flutter/material.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/resources/global.dart';

class SurahAudio extends StatefulWidget {
  final VoidCallback? onTapBack;
  final VoidCallback? onTapNext;
  final VoidCallback? onTapPlay;
  SurahAudio({Key? key, this.onTapBack, this.onTapNext, this.onTapPlay})
      : super(key: key);

  @override
  SurahAudioState createState() => SurahAudioState();
}

class SurahAudioState extends State<SurahAudio> {
  //var cp = '00:00:00';
  //var dr;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AudioConstants.position.toString().split('.')[0],
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  AudioConstants.duration.toString().split('.')[0],
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          slider(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Globals.autoScroll = !Globals.autoScroll;
                    setState(() {});
                  },
                  icon: Image.asset(
                    ImageResource.shuffle,
                    color: Globals.autoScroll ? Colors.white : Colors.white54,
                    width: 25,
                    height: 25,
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: widget.onTapBack,
                        child: const Icon(
                          Icons.skip_previous,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),

                      //

                      InkWell(
                        onTap: widget.onTapPlay,
                        child: Icon(
                          AudioConstants.playing == false
                              ? Icons.play_circle_outline_outlined
                              : Icons.pause_circle_outline_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),

                      //

                      InkWell(
                        onTap: widget.onTapNext,
                        child: const Icon(
                          Icons.skip_next,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      Globals.repeat = !Globals.repeat;
                    });
                  },
                  icon: Image.asset(
                    ImageResource.repeat,
                    color: Globals.repeat ? Colors.white : Colors.white54,
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget slider() {
    return Slider.adaptive(
        activeColor: Color(0xffEC008C),
        inactiveColor: Color(0xff9196A0),
        min: 0.0,
        value: AudioConstants.position.inSeconds.toDouble() > 0.0 &&
                AudioConstants.position.inSeconds.toDouble() <=
                    AudioConstants.duration.inSeconds.toDouble()
            ? AudioConstants.position.inSeconds.toDouble()
            : 0,
        max: AudioConstants.duration.inSeconds.toDouble(),
        onChanged: (double value) {
          setState(() {
            AudioConstants.audioPlayer.seek(Duration(seconds: value.toInt()));
          });
        });
  }
}
