import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:music_app/data/PlaylistData.dart';
import '../data/MusicData.dart';
import 'package:image_picker/image_picker.dart';

class NewPlaylistPage extends StatefulWidget {
  @override
  _NewPlaylistPageState createState() => _NewPlaylistPageState();
}

class _NewPlaylistPageState extends State<NewPlaylistPage> {
  List<Music> _selectedSongs = List<Music>();
  TextEditingController textController = TextEditingController();

  String _playlistImage =
      "https://images7.alphacoders.com/840/thumb-350-840909.png";

  File _image;
  bool _isLoading = false;
  double _progress = 0.0;

  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });

    _uploadImage();
  }

  _uploadImage() async {
    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child("photos")
        .child(DateTime.now().millisecondsSinceEpoch.toString());

    StorageUploadTask task = reference.putFile(_image);
    task.events.listen((e) {
      setState(() {
        _isLoading = true;
        _progress = e.snapshot.bytesTransferred.toDouble() /
            e.snapshot.totalByteCount.toDouble();
      });
    });
    task.onComplete.then((snapshot) {
      setState(() {
        _isLoading = false;
      });
    });
    StorageTaskSnapshot taskSnapshot = await task.onComplete;
    String url = await taskSnapshot.ref.getDownloadURL();
    setState(() {
      _playlistImage = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(textController.text),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              if (!_isLoading) {
                PlaylistMusic playlist = PlaylistMusic.set(
                  name: textController.text,
                  image: _playlistImage,
                  songs: _selectedSongs,
                );

                Firestore.instance
                    .collection("playlists")
                    .document()
                    .setData(playlist.toMap());

                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Playlist criada"),
                        content: Text(
                            "Agora você pode escutar sua playlist, basta encontrá-la na página inicial."),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Ok"),
                          )
                        ],
                      );
                    }).then((m) {
                  Navigator.of(context).pop();
                });
              }
            },
            icon: Icon(Icons.save),
            tooltip: "Salvar",
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _isLoading
                ? LinearProgressIndicator(
                    value: _progress,
                  )
                : SizedBox(),
            SizedBox(
              height: _isLoading ? 8.0 : 0.0,
            ),
            CircleAvatar(
              radius: 72.0,
              backgroundImage: NetworkImage(_playlistImage),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        labelText: "Nome da playlist",
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _getImage();
                    },
                    icon: Icon(Icons.add_photo_alternate),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: Firestore.instance.collection("songs").getDocuments(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      Music music =
                          Music.fromDocument(snapshot.data.documents[index]);
                      bool isSongSelected = false;
                      if (_selectedSongs.length > 0) {
                        for (Music song in _selectedSongs) {
                          if (song.id == music.id) isSongSelected = true;
                        }
                      }

                      return GestureDetector(
                        onTap: () {
                          if (!isSongSelected)
                            setState(() {
                              _selectedSongs.add(music);
                            });
                          else
                            setState(() {
                              _selectedSongs
                                  .removeWhere((song) => song.id == music.id);
                            });
                        },
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 30.0,
                                  backgroundImage: NetworkImage(music.image),
                                ),
                                SizedBox(
                                  width: 16.0,
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(music.name),
                                    Text(music.artist)
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Tooltip(
                                      message: !isSongSelected
                                          ? "Adicionar"
                                          : "Remover",
                                      child: Icon(
                                        (!isSongSelected
                                            ? Icons.add_circle_outline
                                            : Icons.remove_circle_outline),
                                        color: !isSongSelected
                                            ? Colors.yellow
                                            : Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
