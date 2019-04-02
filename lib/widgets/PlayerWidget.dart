import 'package:flutter/material.dart';
import '../data/MusicData.dart';
import 'package:fluttery_audio/fluttery_audio.dart';

class PlayerWidget extends StatefulWidget {
  List<Music> songs;
  AudioPlayer player;
  int songIndex;

  PlayerWidget(this.songs, this.player, this.songIndex);

  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String _timer = "00:00";
  double _songsTime = 0.0;
  final defaultImage =
      "http://saveabandonedbabies.org/wp-content/uploads/2015/08/default.png";

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.player.audioLength != null && widget.player.position != null) {
      _songsTime = widget.player.position.inMilliseconds /
          widget.player.audioLength.inMilliseconds;
      _songsTime *= 100;
      _timer =
          "0" + ((widget.player.position.inSeconds / 60).floor()).toString();
      String _extraZero = "";
      if (widget.player.position.inSeconds % 60 < 10) {
        _extraZero = "0";
      }
      _timer +=
          ":$_extraZero" + (widget.player.position.inSeconds % 60).toString();
    }

    Icon _playerIcon = Icon(Icons.play_circle_outline);
    Function _onPressed;

    if (widget.player.state == AudioPlayerState.playing) {
      _playerIcon = Icon(Icons.pause_circle_outline);
      _onPressed = widget.player.pause;
    } else {
      _playerIcon = Icon(Icons.play_circle_outline);
      _onPressed = widget.player.play;
    }

    return BottomAppBar(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(widget.songs[widget.songIndex].image.isEmpty
                ? defaultImage
                : widget.songs[widget.songIndex].image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4), BlendMode.dstATop),
          ),
        ),
        child: Container(
          color: Color.fromARGB(100, 81, 50, 82),
          height: 135.0,
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                alignment: Alignment.center,
                onPressed: _onPressed,
                icon: _playerIcon,
                iconSize: 92.0,
                color: Colors.white,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.songs[widget.songIndex].artist.isEmpty
                        ? "..."
                        : widget.songs[widget.songIndex].artist.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.songs[widget.songIndex].name.isEmpty
                        ? "..."
                        : widget.songs[widget.songIndex].name,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                  Slider(
                    onChanged: (value) {
                      final seekMillis =
                          ((widget.player.audioLength.inMilliseconds * value) /
                                  100)
                              .round();
                      widget.player
                          .seek(new Duration(milliseconds: seekMillis));
                    },
                    value: _songsTime,
                    activeColor: Color.fromARGB(255, 81, 50, 82),
                    inactiveColor: Colors.white,
                    min: 0.0,
                    max: 100.9,
                  ),
                  Row(
                    children: <Widget>[
                      AudioPlaylistComponent(
                        playlistBuilder: (context, playlist, child) {
                          return IconButton(
                            onPressed: () {
                              playlist.previous();
                              widget.songIndex = playlist.activeIndex;
                            },
                            icon: Icon(Icons.fast_rewind),
                            color: Colors.white,
                          );
                        },
                      ),
                      Text(
                        _timer,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      AudioPlaylistComponent(
                        playlistBuilder: (context, playlist, child) {
                          return IconButton(
                            onPressed: () {
                              playlist.next();
                              widget.songIndex = playlist.activeIndex;
                            },
                            icon: Icon(Icons.fast_forward),
                            color: Colors.white,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
