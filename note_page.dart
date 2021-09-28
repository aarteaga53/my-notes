import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/take_picture_page.dart';
import 'package:path_provider/path_provider.dart';

class NotePage extends StatefulWidget {
  //const NotePage({Key? key}) : super(key: key);

  var notePath;

  NotePage(this.notePath, {Key? key}) : super(key: key);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {

  int noteCounter = 2;
  PageController pageController = PageController();
  var notes = [];

  @override
  void initState() {
    super.initState();

    notes.add(widget.notePath['image']);
  }

  void incrementNoteCounter() {
    setState(() {
      noteCounter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(widget.notePath['title'])
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
            child: PageView.builder(
              controller: pageController,
              itemCount: notes.length,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  child: Image(
                    image: FileImage(File(notes[index])),
                    //image: FileImage(File(widget.notePath['image'])),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 10,
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    final cameras = await availableCameras();
                    final firstCamera = cameras.first;

                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera))
                    );
                    final picture = File(result);

                    var filename = widget.notePath['path'] + '/Note' + noteCounter.toString() + '.jpeg';
                    final file = File(filename);
                    file.writeAsBytesSync(picture.readAsBytesSync());

                    notes.add(filename);
                    incrementNoteCounter();
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
