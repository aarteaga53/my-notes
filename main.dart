import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mynotes/take_picture_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
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
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
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

  @override
  void initState() {
    super.initState();
    setState(() {
      loadNoteCounter();
      loadNoteList();
    });
  }

  void loadNoteCounter() async {
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('noteCounter');
    noteCounter = prefs.getInt('noteCounter') ?? 1;
  }

  void incrementNoteCounter() async {
    final prefs = await SharedPreferences.getInstance();
    noteCounter++;
    prefs.setInt('noteCounter', noteCounter);
    setState(() {

    });
  }

  Future<String> getFilepath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void createNote(String filepath, String filename) {
    var note = {
      'image' : filename,
      'title' : 'Note' + noteCounter.toString(),
    };

    noteList.add(note);

    final file = File('$filepath/noteList.txt');
    file.writeAsStringSync('Note List\n');
    for (var element in noteList) {
      file.writeAsStringSync(element['image'] + '\n', mode: FileMode.append);
      file.writeAsStringSync(element['title'] + '\n', mode: FileMode.append);
    }
    //file.delete();
  }

  void loadNoteList() async {
    String filepath = await getFilepath();
    if(File('$filepath/noteList.txt').existsSync()) {
      final file = File('$filepath/noteList.txt');

      List<String> lines = file.readAsLinesSync();

      for(int i = 1; i < lines.length - 1; i++) {
        var note = {
          'image' : lines[i],
          'title' : lines[++i],
        };
        noteList.add(note);
      }
    }

  }

  void createPDF(var pdf, File picture) {
    final image = pw.MemoryImage(picture.readAsBytesSync());
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.FullPage(
            ignoreMargins: true,
              child: pw.Image(image, fit: pw.BoxFit.cover)
          );
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 5,
          mainAxisSpacing: 10,
        ),
        itemCount: noteList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotePage(noteList[index])),
                  );
                },
                onLongPress: () {

                },
                title: Column(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: IgnorePointer(
                        child: SfPdfViewer.file(
                          File(noteList[index]['image']),
                          canShowScrollHead: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(noteList[index]['title']),
                  ]
              ),
            ],
          );
        },

      ),
      floatingActionButton: SpeedDial(
        icon: Icons.create,
        children: [
          SpeedDialChild(
            onTap: () async {
              final cameras = await availableCameras();
              final firstCamera = cameras.first;

              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera))
              );

              final picture = File(result);
              var pdf = pw.Document();
              createPDF(pdf, picture);

              String filepath = await getFilepath();
              String filename = filepath + '/Note' + noteCounter.toString() + '.pdf';
              final file = File(filename);
              file.writeAsBytes(await pdf.save());

              createNote(filepath, filename);
              incrementNoteCounter();
            },
            label: 'Take Picture',
            child: const Icon(Icons.add_a_photo),
            backgroundColor: Colors.lightBlueAccent,
          ),
          SpeedDialChild(
            onTap: () async {
              PickedFile? pickedFile = (await ImagePicker().pickImage(
                source: ImageSource.gallery,
              )) as PickedFile?;

              final imageFile = File(pickedFile!.path);
              var pdf = pw.Document();
              createPDF(pdf, imageFile);

              String filepath = await getFilepath();
              String filename = filepath + '/Note' + noteCounter.toString() + '.pdf';
              final file = File(filename);
              file.writeAsBytes(await pdf.save());

              createNote(filepath, filename);
              incrementNoteCounter();
            },
            label: 'Add Image',
            child: const Icon(Icons.add_photo_alternate),
            backgroundColor: Colors.lightBlueAccent,
          ),
          SpeedDialChild(
            onTap: () {

            },
            label: 'Create Folder',
            child: const Icon(Icons.create_new_folder),
            backgroundColor: Colors.lightBlueAccent,
          )
        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
