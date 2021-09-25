import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class NotePage extends StatefulWidget {
  //const NotePage({Key? key}) : super(key: key);

  String title;

  NotePage(this.title, {Key? key}) : super(key: key);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {

  String notePath = "";

  @override
  void initState() {
    super.initState();
    loadNotePath().then((path) {
      notePath = path;
      setState(() {

      });
    });
  }

  Future<String> loadNotePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return '$path/' + widget.title + '.jpeg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(widget.title)
        ),
        actions: [
          IconButton(
              onPressed: () {

              },
              icon: const Icon(Icons.edit),

    )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 90,
            child: SizedBox(

              child: Image(
                  image: FileImage(File(notePath)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {

                  },
                  icon: const Icon(Icons.camera_alt),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {

                  },
                  icon: const Icon(Icons.reorder),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {

                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
