import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttery_audio/fluttery_audio.dart';
import 'package:music_app/pages/NewPlaylistPage.dart';
import 'package:music_app/pages/SongsPage.dart';
import 'data/PlaylistData.dart';

void main() {
  runApp(
    MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF8C0032),
        accentColor: Color(0xFFFA5788),
      ),
    ),
  );
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Playlist públicas"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NewPlaylistPage(),
                ),
              );
            },
            icon: Icon(Icons.playlist_add),
            tooltip: "Nova Playlist",
          )
        ],
      ),
      body: Container(
        child: FutureBuilder<QuerySnapshot>(
          future: Firestore.instance.collection("playlists").getDocuments(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
              List documents = snapshot.data.documents.reversed.toList();
            return Container(
              child: ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  PlaylistMusic playlist = PlaylistMusic.fromDocument(
                      documents[index]);
                  return Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SongsPage(playlist),
                          ),
                        );
                      },
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 30.0,
                                backgroundImage: NetworkImage(playlist.image),
                              ),
                              SizedBox(
                                width: 16.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(playlist.name),
                                ],
                              ),
                            ],
                          ),
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
    );
  }
}

class PlayerPage extends StatefulWidget {
  String url;
  PlayerPage(this.url);
  @override
  _PlayerPageState createState() => _PlayerPageState(url);
}

class _PlayerPageState extends State<PlayerPage> {
  String url;

  _PlayerPageState(this.url);

  @override
  Widget build(BuildContext context) {
    return Audio(
      audioUrl: url,
      playbackState: PlaybackState.playing,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Tocando"),
        ),
        body: Container(
          child: AudioComponent(
            updateMe: [
              WatchableAudioProperties.audioPlayerState,
            ],
            playerBuilder: (context, player, child) {
              return IconButton(
                onPressed: () {
                  player.stop();
                  Navigator.pop(context);
                },
                icon: Icon(Icons.pause_circle_outline),
                tooltip: "Parar",
              );
            },
          ),
        ),
      ),
    );
  }
}
