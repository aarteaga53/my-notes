import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'note.dart';
import 'note_page.dart';

//ignore: must_be_immutable
class FavoritePage extends StatefulWidget {
  FavoritePage(this.notes, this.favorites, this.viewType, {Key? key}) : super(key: key);

  List<Note> notes;
  List<Note> favorites;
  String viewType;

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {

  void saveFavoriteList() async {
    widget.favorites.sort((a, b) => a.title.compareTo(b.title));

    String filepath = await getFilepath();
    final file = File('$filepath/favoriteList.txt');
    file.writeAsStringSync('Image Path,Folder Path,Title,Timestamp,Favorite\n');

    for (var element in widget.favorites) {
      file.writeAsStringSync(element.imagepath + ',' + element.folderpath + ',' +
          element.title + ',' + element.timestamp.toString() + ',' + element.favorite + '\n',
          mode:  FileMode.append
      );
    }
    setState(() {

    });
  }

  Future<String> getFilepath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void unfavoriteNote(int index) {
    widget.notes[widget.notes.indexWhere((element) => element.imagepath == widget.favorites[index].imagepath)].favorite = 'no';
    widget.favorites.removeAt(index);
    saveFavoriteList();
  }

  void showBottom(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Row(
          children: [
            Expanded(
              //flex: 50,
              child: TextButton(
                onPressed: () {
                  unfavoriteNote(index);
                  Navigator.pop(context);
                },
                child: const Text('Unfavorite',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void noteTap(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotePage(widget.favorites[index])),
    );
    saveFavoriteList();
    widget.notes[widget.notes.indexWhere((element) => element.imagepath == widget.favorites[index].imagepath)].title = widget.favorites[index].title;
  }

  String timeFormat(int index) {
    var time = DateTime.fromMillisecondsSinceEpoch(widget.favorites[index].timestamp);
    var current = DateTime.now();

    if(time.day == current.day && time.year == current.year) {
      return DateFormat('h:mm a').format(time);
    }
    else if(time.year == time.year) {
      return DateFormat.Md().format(time);
    }
    else {
      return DateFormat.yMd().format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.blueGrey,
            iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
            title: Center(
              child: Text(
                'Favorites',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            actions: [
              Center(
                child: PopupMenuButton(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)
                    ),
                  ),
                  icon: const Icon(Icons.more_vert),
                  onSelected: (String? newValue){
                    setState(() {
                      if(newValue == 'Remove') {
                        for(int i = widget.favorites.length-1; i >= 0; i--) {
                          unfavoriteNote(i);
                        }
                      }
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Remove',
                      child: Text('Remove Favorites'),
                    ),
                  ],
                ),
              )
            ],
          ),
          widget.viewType == 'Grid' ?
          SliverPadding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 25,
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 1.65),
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () => noteTap(index),
                      onLongPress: () => showBottom(index),
                      title: Container(
                        height: 100,
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            image: FileImage(File(widget.favorites[index].imagepath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      subtitle: Center(
                        child: Column(
                          children: [
                            widget.favorites[index].title.length <= 9 ? Text(widget.favorites[index].title,
                              style: Theme.of(context).textTheme.bodyText2,
                            ) :
                            Text(
                              widget.favorites[index].title.substring(0, 9) + '...',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            Text(timeFormat(index),
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: widget.favorites.length,
              ),
            ),
          ) :
          SliverPadding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () => noteTap(index),
                      onLongPress: () => showBottom(index),
                      title: SizedBox(
                        height: 100,
                        child: Row(
                          children: [
                            Container(
                              width: 85,
                              height: 85,
                              margin: const EdgeInsets.only(right: 25),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                  image: FileImage(File(widget.favorites[index].imagepath)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.favorites[index].title.length <= 15 ? Text(widget.favorites[index].title,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ) :
                                Text(
                                  widget.favorites[index].title.substring(0, 15) + '...',
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                Text(timeFormat(index),
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.star),
                              onPressed: () => unfavoriteNote(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: widget.favorites.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
