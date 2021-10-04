import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NotePage extends StatefulWidget {
  //const NotePage({Key? key}) : super(key: key);

  var notePath;

  NotePage(this.notePath, {Key? key}) : super(key: key);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {

  TextEditingController titleController = TextEditingController();
  TextEditingController pageController = TextEditingController();
  bool isEditingText = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.notePath['title']);
  }

  void modifyPDF(File picture) {
    PdfDocument document = PdfDocument(inputBytes: File(widget.notePath['pdfPath']).readAsBytesSync());
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
    final file = File(widget.notePath['pdfPath']);
    file.writeAsBytes(document.save());
    document.dispose();
    setState(() {

    });
  }

  void deletePage(int pageNum) {
    PdfDocument document = PdfDocument(inputBytes: File(widget.notePath['pdfPath']).readAsBytesSync());
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
            widget.notePath['title'] = newValue;
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
      child: Text(
        widget.notePath['title'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, widget.notePath['title']);
          },
        ),
        title: editTitleTextField(),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 90,
            child: SfPdfViewer.file(
              File(widget.notePath['pdfPath']), pageSpacing: 10,
              canShowScrollHead: false,
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

                  },
                  icon: const Icon(Icons.reorder),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    showDialog(context: context, builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Page'),
                        actions: [
                          TextField(
                            controller: pageController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Enter page number ',
                              )
                          ),
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
