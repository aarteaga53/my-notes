import 'dart:io';
import 'package:flutter/material.dart';
import 'note.dart';

//ignore: must_be_immutable
class ReorderPage extends StatefulWidget {
  ReorderPage(this.note, this.images, {Key? key}) : super(key: key);

  Note note;
  List<String> images;

  @override
  _ReorderPageState createState() => _ReorderPageState();
}

class _ReorderPageState extends State<ReorderPage> {

  TextEditingController moveController = TextEditingController();

  Future<void> movePage(int index, int position) async {
    if(index != position && position >= 0 && position < widget.images.length) {
      String filename = widget.images[index];
      widget.images.removeAt(index);
      widget.images.insert(position, filename);

      for(int i = position; i < widget.images.length; i++) {
        File image = File(widget.images[i]);
        var timestamp = DateTime.now().microsecondsSinceEpoch;
        String filename = widget.note.folderpath + '/$timestamp.jpeg';
        image.rename(filename);
        widget.images[i] = filename;
      }

      widget.note.timestamp = DateTime.now().millisecondsSinceEpoch;
    }
    if(index == 0 || position == 0) {
      widget.note.imagepath = widget.images[0];
    }

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        title: const Text('Reorder Notes'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(5),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              showDialog(context: context, builder: (BuildContext context) {
                return AlertDialog(
                  contentPadding: const EdgeInsets.only(top: 15, right: 25, left: 25, bottom: 0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  title: const Text('Move Page'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 5),
                      TextField(
                        controller: moveController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter position to move to:',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            moveController.clear();
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await movePage(index, int.parse(moveController.text)-1);
                            moveController.clear();
                            Navigator.pop(context);
                          },
                          child: const Text('Enter'),
                        ),
                      ],
                    ),
                  ],
                );
              });
            },
            child: GridTile(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(widget.images[index])),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              footer: GridTileBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      (index+1).toString(),
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
