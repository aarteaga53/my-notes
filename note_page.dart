import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'note_list.dart';

class NotePage extends StatefulWidget {
  NotePage(this.note, {Key? key}) : super(key: key);

  NoteList note;

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {

  TextEditingController pageController = TextEditingController();
  TextEditingController moveController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  bool isEditingText = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    setState(() {

    });
  }

  void modifyPDF(File picture) {
    PdfDocument document = PdfDocument(inputBytes: File(widget.note.pdfPath).readAsBytesSync());
    Uint8List imageData = picture.readAsBytesSync();
    PdfBitmap image = PdfBitmap(imageData);
    PdfPage page = document.pages[document.pages.count-1];
    page.graphics.drawImage(
        image,
        Rect.fromLTWH(0, 0, page.getClientSize().width, page.getClientSize().height)
    );
    document.pages.add();

    savePDF(document);
  }

  void savePDF(PdfDocument document) {
    final file = File(widget.note.pdfPath);
    file.writeAsBytes(document.save());
    document.dispose();
    setState(() {
      widget.note.timestamp = DateTime.now().millisecondsSinceEpoch;
    });
  }

  void deletePage(int pageNum) {
    PdfDocument document = PdfDocument(inputBytes: File(widget.note.pdfPath).readAsBytesSync());
    if(pageNum < document.pages.count) {
      document.pages.removeAt(pageNum - 1);
      savePDF(document);
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, widget.note.title);
          },
        ),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        title: editTitleTextField(),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 90,
            child: SfPdfViewer.file(
              File(widget.note.pdfPath),
              pageSpacing: 10,
              canShowScrollHead: false,
              pageLayoutMode: PdfPageLayoutMode.single,
            ),
          ),
          Expanded(
            flex: 10,
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    XFile? picture = await ImagePicker().pickImage(
                        source: ImageSource.camera
                    );

                    final pictureFile = File(picture!.path);
                    modifyPDF(pictureFile);
                  },
                  icon: const Icon(Icons.add_a_photo),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    XFile? image = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );

                    final imageFile = File(image!.path);
                    modifyPDF(imageFile);
                  },
                  icon: const Icon(Icons.add_photo_alternate)
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    showDialog(context: context, builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Page'),
                        content: TextField(
                            controller: pageController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter page number:',
                            )
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  pageController.clear();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  deletePage(int.parse(pageController.text));
                                  Navigator.pop(context);
                                  pageController.clear();
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}
