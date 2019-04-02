import 'package:cloud_firestore/cloud_firestore.dart';

class Music {
  String id;
  String name;
  String artist;
  String url;
  String image;

  Music();

  Music.fromDocument(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    name = snapshot.data["name"];
    artist = snapshot.data["artist"];
    url = snapshot.data["url"];
    image = snapshot.data["image"];
  }

  Map<String, dynamic> toMap() {
    return {'id': id,'name': name, 'artist': artist, 'url': url, 'image': image};
  }

  Map<String, dynamic> toMapId() {
    return {'id': id};
  }
}