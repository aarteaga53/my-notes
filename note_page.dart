import 'package:flutter/material.dart';

class NotePage extends StatefulWidget {
  //const NotePage({Key? key}) : super(key: key);

  String title;

  NotePage(this.title);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 10,
                  child: Icon(Icons.arrow_back)
              ),
              Expanded(
                flex: 80,
                  child: Center(child: Text(widget.title))
              ),
              Expanded(
                flex: 10,
                child: Icon(Icons.edit),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
