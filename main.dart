import 'package:flutter/material.dart';
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
  var noteList = [];

  void incrementNoteCounter() {
    setState(() {
      noteCounter++;
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
                MaterialPageRoute(builder: (context) => NotePage(noteList[index]['title'])),
              );
            },
            title: Container(
              height: 150,
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Image(
                          image: NetworkImage(noteList[index]['image']),
                        ),
                      ),
                      Text(noteList[index]['title']),
                    ]
                  ),
                ],
              ),
            ),
          );
        },

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var note = {
            'image' : 'https://images.squarespace-cdn.com/content/v1/59aeaca4197aeadddeef26f8/1539332634579-K6JZ3B79E3R657I2C090/Logo+for+Standard+Notes.png?format=1000w',
            'title' : 'Note' + noteCounter.toString(),
          };
          noteList.add(note);
          incrementNoteCounter();
        },
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
