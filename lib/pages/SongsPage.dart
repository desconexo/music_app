import 'package:flutter/material.dart';
import 'package:fluttery_audio/fluttery_audio.dart';
import 'package:music_app/data/PlaylistData.dart';
import 'package:music_app/widgets/PlayerWidget.dart';

class SongsPage extends StatefulWidget {
  PlaylistMusic _playlist;

  SongsPage(this._playlist);

  @override
  _SongsPageState createState() => _SongsPageState(_playlist);
}

class _SongsPageState extends State<SongsPage> {
  PlaylistMusic _playlist;
  _SongsPageState(this._playlist);
  int _songIndex = 0;
  RepeatStatus repeat = RepeatStatus.norepeat;

  @override
  Widget build(BuildContext context) {
    if (_playlist.songs.length <= 0)
      return AlertDialog(
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Ok"),
          ),
        ],
        title: Text("Opa, algo deu errado..."),
        content: Container(
          child: Text(
              "Não conseguimos carregar essa playlist, tente novamente mais tarde."),
        ),
      );
    return AudioPlaylist(
      reapetStatus: repeat,
      playlist: _playlist.songs.map((song) {
        return song.url;
      }).toList(growable: false),
      playbackState: PlaybackState.paused,
      child: AudioComponent(
        playerBuilder: (context, player, child) {
          return WillPopScope(
            onWillPop: () async {
              if (player.state == AudioPlayerState.playing)
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Opa..."),
                        content: Text(
                            "Se você sair desta página sua música vai parar!"),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Ficar"),
                          ),
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              player.stop();
                              Navigator.of(context).pop();
                            },
                            child: Text("Sair"),
                          )
                        ],
                      );
                    });
              else
                return true;
              return false;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(_playlist.name.isEmpty ? "..." : _playlist.name),
                actions: <Widget>[
                  setPlaylistRepeatButton(),
                ],
              ),
              body: Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  child: ListView.builder(
                    itemCount: _playlist.songs.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: AudioPlaylistComponent(
                          playlistBuilder: (context, playlist, child) {
                            _songIndex = playlist.activeIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  playlist.setActiveIndex(index);
                                  _songIndex = index;
                                });
                              },
                              child: Card(
                                color: playlist.activeIndex == index
                                    ? Theme.of(context).accentColor
                                    : Colors.white,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 30.0,
                                        backgroundImage: NetworkImage(
                                            _playlist.songs[index].image),
                                      ),
                                      SizedBox(
                                        width: 16.0,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _playlist.songs[index].name,
                                            style: TextStyle(
                                              color:
                                                  playlist.activeIndex == index
                                                      ? Colors.white
                                                      : Colors.grey[800],
                                            ),
                                          ),
                                          Text(_playlist.songs[index].artist,
                                              style: TextStyle(
                                                color: playlist.activeIndex ==
                                                        index
                                                    ? Colors.white
                                                    : Colors.grey[800],
                                              ))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              bottomNavigationBar: AudioComponent(
                updateMe: [
                  WatchableAudioProperties.audioPlayerState,
                  WatchableAudioProperties.audioPlayhead,
                  WatchableAudioProperties.audioSeeking,
                  WatchableAudioProperties.audioBuffering,
                ],
                playerBuilder: (context, player, child) {
                  if (_playlist.songs.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return PlayerWidget(_playlist.songs, player, _songIndex);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget setPlaylistRepeatButton() {
    if (repeat == RepeatStatus.norepeat) {
      return IconButton(
        icon: Icon(Icons.repeat),
        color: Colors.white,
        onPressed: () => _playlistRepeat(RepeatStatus.repeat),
        tooltip: "Repetir",
      );
    } else if (repeat == RepeatStatus.repeat) {
      return IconButton(
        icon: Icon(Icons.repeat),
        color: Theme.of(context).accentColor,
        onPressed: () => _playlistRepeat(RepeatStatus.repeatonly),
        tooltip: "Repetir uma",
      );
    } else {
      return IconButton(
        icon: Icon(Icons.repeat_one),
        color: Theme.of(context).accentColor,
        onPressed: () => _playlistRepeat(RepeatStatus.norepeat),
        tooltip: "Não repetir",
      );
    }
  }

  _playlistRepeat(RepeatStatus status) {
    switch (status) {
      case RepeatStatus.norepeat:
        setState(() => repeat = RepeatStatus.norepeat);
        break;
      case RepeatStatus.repeat:
        setState(() => repeat = RepeatStatus.repeat);
        break;
      case RepeatStatus.repeatonly:
        setState(() => repeat = RepeatStatus.repeatonly);
        break;
      default:
        _playlistRepeat(RepeatStatus.norepeat);
        break;
    }
  }
}
