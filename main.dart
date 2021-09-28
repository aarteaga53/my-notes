import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/take_picture_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Notes',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'My Notes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int noteCounter = 1;
  List noteList = [];

  void incrementNoteCounter() {
    setState(() {
      noteCounter++;
    });
  }

  void decrementNoteCounter() {
    setState(() {
      noteCounter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: ListView.builder(
        itemCount: noteList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotePage(noteList[index])),
              );
            },
            onLongPress: () {

            },
            title: Container(
              height: 100,
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(File(noteList[index]['image'])),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(noteList[index]['title']),
                      // IconButton(
                      //   onPressed: () async {
                      //     final file = File(noteList[index]['image']);
                      //     await file.delete();
                      //     noteList.removeAt(noteCounter-2);
                      //     decrementNoteCounter();
                      //   },
                      //   icon: const Icon(Icons.delete),
                      // ),
                    ]
                  ),
                ],
              ),
            ),
          );
        },

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
           final cameras = await availableCameras();
           final firstCamera = cameras.first;

           final result = await Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera))
           );
           final picture = File(result);

           final directory = await getApplicationDocumentsDirectory();
           final path = directory.path;
           var newDirectory = '$path/note' + noteCounter.toString();
           Directory(newDirectory).create(recursive: true);
           var filename = newDirectory + '/Note1.jpeg';
           final file = File(filename);
           file.writeAsBytesSync(picture.readAsBytesSync());

           var note = {
             'image' : filename,
             'title' : 'Note' + noteCounter.toString(),
             'path' : newDirectory,
           };

           noteList.add(note);
           incrementNoteCounter();
         },
         child: const Icon(Icons.camera_alt),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
