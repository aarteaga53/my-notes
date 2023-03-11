import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mynotes/reorder_page.dart';
import 'package:photo_view/photo_view.dart';
import 'note.dart';

//ignore: must_be_immutable
class NotePage extends StatefulWidget {
  NotePage(this.note, {Key? key}) : super(key: key);

  Note note;

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {

  List<String> images = <String>[];
  PageController imageController = PageController();
  TextEditingController pageController = TextEditingController();
  TextEditingController moveController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  bool isEditingText = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    loadImages();
    setState(() {

    });
  }

  void loadImages() {
    final files = Directory(widget.note.folderpath).listSync(recursive: true, followLinks: false);

    for(var element in files) {
      images.add(element.path);
    }

    images.sort((a, b) => a.substring(a.lastIndexOf('/')).compareTo(b.substring(b.lastIndexOf('/'))));
  }

  void addPage(File picture) {
    var timestamp = DateTime.now().microsecondsSinceEpoch;
    final filename = widget.note.folderpath + '/$timestamp.jpeg';
    final file = File(filename);
    file.writeAsBytes(picture.readAsBytesSync());
    images.add(filename);
    widget.note.timestamp = DateTime.now().millisecondsSinceEpoch;
    setState(() {

    });
  }

  void deletePage(int pageNum) async {
    if(pageNum == 1 && images.length == 1) {
      await Directory(widget.note.folderpath).delete(recursive: true);
      Navigator.pop(context);
    }
    if(pageNum <= images.length && pageNum > 0) {
      File(images[pageNum-1]).delete();
      images.removeAt(pageNum-1);
      if(pageNum == 1) {
        widget.note.imagepath = images[0];
      }
      setState(() {

      });
    }
  }

  void movePage(int pageNum, int position) {
    if(pageNum != position && pageNum > 0 && pageNum <= images.length && position > 0 && position <= images.length) {
      final image = File(images[pageNum-1]);
      int previous = int.parse(images[pageNum-2].substring(images[pageNum-2].lastIndexOf('/')+1, images[pageNum-2].lastIndexOf('.'))) + 1;
      final filename = widget.note.folderpath + '/$previous.jpeg';
      final file = File(filename);
      file.writeAsBytes(image.readAsBytesSync());
      image.delete();
      widget.note.timestamp = DateTime.now().millisecondsSinceEpoch;

      images.removeAt(pageNum-1);
      images.insert(position-1, filename);

      setState(() {

      });
    }
  }

  Widget editTitleTextField() {
    if(isEditingText) {
      return TextField(
        onSubmitted: (newValue) {
          setState(() {
            widget.note.title = newValue;
            widget.note.timestamp = DateTime.now().millisecondsSinceEpoch;
            isEditingText = false;
          });
        },
        autofocus: true,
        controller: titleController,
      );
    }
    return InkWell(
      onTap: () {
        setState(() {
          isEditingText = true;
        });
      },
      child: Text(widget.note.title,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        title: editTitleTextField(),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 90,
            child: PageView.builder(
              controller: imageController,
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  child: PhotoView(
                    imageProvider: FileImage(File(images[index])),
                    backgroundDecoration: BoxDecoration(color: Theme.of(context).cardColor),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 10,
            child: Container(
              color: Colors.blueGrey,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      XFile? picture = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                      );

                      final pictureFile = File(picture!.path);
                      addPage(pictureFile);
                    },
                    icon: const Icon(Icons.add_a_photo),
                    color: Theme.of(context).cardColor,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      XFile? image = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );

                      final imageFile = File(image!.path);
                      addPage(imageFile);
                    },
                    icon: const Icon(Icons.add_photo_alternate),
                    color: Theme.of(context).cardColor,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () async{
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReorderPage(widget.note, images)),
                      );
                      setState(() {

                      });
                    },
                    icon: const Icon(Icons.reorder),
                    color: Theme.of(context).cardColor,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      showDialog(context: context, builder: (BuildContext context) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.only(top: 15, right: 25, left: 25, bottom: 0),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          title: const Text('Delete Page'),
                          content: TextField(
                            controller: pageController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter page number:',
                            ),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    pageController.clear();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    deletePage(int.parse(pageController.text));
                                    pageController.clear();
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
                    icon: const Icon(Icons.delete),
                    color: Theme.of(context).cardColor,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
