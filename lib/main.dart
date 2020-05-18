import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String pathPDF = "";

  @override
  void initState() {
    super.initState();
    fromAsset('assets/pdfFiles/evrad_AR.pdf', 'evrad_AR.pdf').then((f) {
      setState(() {
        pathPDF = f.path;
      });
    });
  }

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PDF View',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: themeColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(child: Builder(
          builder: (BuildContext context) {
            return Column(
              children: <Widget>[
                RaisedButton(
                  child: Text("Open PDF"),
                  onPressed: () {
                    if (pathPDF != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFScreen(path: pathPDF),
                        ),
                      );
                    }
                  },
                )
              ],
            );
          },
        )),
      ),
    );
  }
}

MaterialColor themeColor = const MaterialColor(0xFF2D45CB,
    const {
      50 : const Color(0xFF2D45CB),
      100 : const Color(0xFF2D45CB),
      200 : const Color(0xFF2D45CB),
      300 : const Color(0xFF2D45CB),
      400 : const Color(0xFF2D45CB),
      500 : const Color(0xFF2D45CB),
      600 : const Color(0xFF2D45CB),
      700 : const Color(0xFF2D45CB),
      800 : const Color(0xFF2D45CB),
      900 : const Color(0xFF2D45CB)});

class PDFScreen extends StatefulWidget {
  final String path;

  PDFScreen({Key key, this.path}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
  Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  double readSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            defaultPage: currentPage,
            fitPolicy: FitPolicy.HEIGHT,
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onPageChanged: (int page, int total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
              ? Center(
            child: CircularProgressIndicator(),
          )
              : Container()
              : Center(
            child: Text(errorMessage),
          )
        ],
      ),
      drawer: Container(
        width: 250,
        child: Drawer(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/nav_background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: const <Widget>[
                SizedBox(
                  height: 145,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/wallpaper.jpg"),
                          fit: BoxFit.cover
                      ),
                      color: Color(0xFF2D45CB),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.bookmark_border, color: Color(0xFF2E44CB),),
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0,),
                  dense:true,
                  title: Text('Ayraç',style: TextStyle(color: Color(0xFF223598)),),
                ),
                ListTile(
                  leading: Icon(Icons.favorite_border, color: Color(0xFF2E44CB),),
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0,),
                  dense:true,
                  title: Text('Favoriler',style: TextStyle(color: Color(0xFF223598)),),
                ),
                ListTile(
                  leading: Icon(Icons.graphic_eq, color: Color(0xFF2E44CB),),
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0,),
                  dense:true,
                  title: Text('Günlük Evrad',style: TextStyle(color: Color(0xFF223598)),),
                ),
                ListTile(
                  leading: Icon(Icons.graphic_eq, color: Color(0xFF2E44CB),),
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0,),
                  dense:true,
                  title: Text('Pazartesi Evradı',style: TextStyle(color: Color(0xFF223598)),),
                ),
                ListTile(
                  leading: Icon(Icons.graphic_eq, color: Color(0xFF2E44CB),),
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0,),
                  dense:true,
                  title: Text('Salı Evradı',style: TextStyle(color: Color(0xFF223598)),),
                ),
                ListTile(
                  leading: Icon(Icons.graphic_eq, color: Color(0xFF2E44CB),),
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0,),
                  dense:true,
                  title: Text('Çarşamba Evradı',style: TextStyle(color: Color(0xFF223598)),),
                ),
                ListTile(
                  leading: Icon(Icons.graphic_eq, color: Color(0xFF2E44CB),),
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0,),
                  dense:true,
                  title: Text('Perşembe Evradı',style: TextStyle(color: Color(0xFF223598)),),
                ),
                ListTile(
                  leading: Icon(Icons.graphic_eq, color: Color(0xFF2E44CB),),
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0,),
                  dense:true,
                  title: Text('Cuma Evradı',style: TextStyle(color: Color(0xFF223598)),),
                ),
                ListTile(
                  leading: Icon(Icons.graphic_eq, color: Color(0xFF2E44CB),),
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0,),
                  dense:true,
                  title: Text('Cumartesi Evradı',style: TextStyle(color: Color(0xFF223598)),),
                ),
                ListTile(
                  leading: Icon(Icons.graphic_eq, color: Color(0xFF2E44CB),),
                  title: Text('Pazar Evradı',style: TextStyle(color: Color(0xFF223598)),),
                ),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Color(0xFF2E44CB),),
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0,),
                  dense:true,
                  title: Text('Bilgilendirme',style: TextStyle(color: Color(0xFF223598)),),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: themeColor,
        elevation: 5,
        child: Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: <Widget>[
                        IconButton(
                          onPressed: showMenu,
                          color: themeColor,
                          icon: Icon(Icons.import_contacts, color:Colors.white,),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: <Widget>[
                        IconButton(
                          onPressed: showMenu,
                          color: themeColor,
                          icon: Icon(Icons.av_timer, color:Colors.white,),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: <Widget>[
                        IconButton(
                          color: themeColor,
                          icon: Icon(Icons.playlist_add, color:Colors.white,),
                          onPressed: () {
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.play_arrow),
        backgroundColor: Colors.orange,
      ),
    );
  }

  showMenu() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: Color(0xff223598),
              boxShadow: [
                BoxShadow(color: Color(0xff223598), spreadRadius: 4),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: 36,
                ),
                SizedBox(
                    height: 120,
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                          color: Color(0xff2e44cb),
                        ),
                        child: Stack(
                          alignment: Alignment(0, 0),
                          overflow: Overflow.visible,
                          children: <Widget>[
                            Positioned(
                              top: -26,
                              child: Container(
                                height: 60,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.orange,
                                  child: Center(
                                      child: Text(readSpeed.toStringAsFixed(2),
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),)
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              child: ListView(
                                children: <Widget>[
                                  Padding(
                                      padding: const EdgeInsets.only(top:45),
                                      child: Text('OKUMA HIZI',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),)
                                  ),
                                  Slider(
                                    value: readSpeed,
                                    activeColor: Colors.orange,
                                    inactiveColor: Colors.white,
                                    min: 0.25,
                                    max: 2.50,
                                    divisions: 9,
                                    label: '$readSpeed',
                                    onChanged: (value) {
                                      setState(() { readSpeed = value; });
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ))),
              ],
            ),
          );
        });
  }
}