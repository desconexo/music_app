import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'MusicData.dart';

class PlaylistMusic {
  String name;
  List<Music> songs = List();
  String image = "https://images7.alphacoders.com/840/thumb-350-840909.png";

  PlaylistMusic();

  PlaylistMusic.set({
    @required this.name,
    @required this.image,
    @required this.songs,
  });

  PlaylistMusic.fromDocument(DocumentSnapshot snapshot) {
    name = snapshot.data["name"];
    image = snapshot.data["image"];
    for (String id in snapshot.data["songs"]) {
      Firestore.instance.collection("songs").document(id).get().then((song) {
        /*Music music = Music();
        music.name = song.data["name"];
        music.artist = song.data["artist"];
        music.image = song.data["image"];
        music.url = song.data["url"];
        */
        songs.add(Music.fromDocument(song));
      });
    }
  }

  Map<String, dynamic> toMap() {
    List<String> songsId = List<String>();
    for (Music m in songs) {
      songsId.add(m.id);
    }
    return {
      'name': name,
      'image': image,
      'songs': songsId,
    };
  }
}
