import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Textify',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '',),
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
  File? file = null;
  final ImagePicker picker = ImagePicker();
  String text = 'Text in the image will be displayed here...';
  bool isUploading = false, textChanged = false;

  Future<bool> _choose() async {
    textChanged = true;
    final XFile? image = (await picker.pickImage(source: ImageSource.gallery));
    file = File(image!.path);
    if(file == null){
      setState(() {text = '';});
      return true;
    } else {
      String ext_4 = file.toString().substring(file.toString().length - 4);
      String ext_5 = file.toString().substring(file.toString().length - 5);
      if(ext_4 == "jpg'" || ext_4 == "png'" || ext_5 == "jpeg'"){
        setState(() {});
        if(file == null)
          setState(() {text = '';});
        return true;
      }
      else
        return false;
    }
  }

  void _capture() async {
    textChanged = true;
    final XFile? image = (await picker.pickImage(source: ImageSource.camera));
    file = File(image!.path);
    if(file == null)
      setState(() {text = '';});
    else
      setState(() {});
  }

  Future<bool> _upload() async {  
    textChanged = true;
    setState(() {text = '';});
    isUploading = true;
    print(file!.path);
    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse('https://mohitkambli.pythonanywhere.com/process'));
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        file!.path,
      ),
    );
    http.StreamedResponse r = await request.send();
    text += await r.stream.transform(utf8.decoder).join();

    // const url = 'https://mohitkambli.pythonanywhere.com/process'; // Replace with your Python server URL
    // final response = await http.post(
    //   Uri.parse(url),
    //   body: {
    //     'image': file!.path
    //   },
    // );
    // if (response.statusCode == 200) {
    //   // Success! Handle the response here
    //   print(response.body);
    // } else {
    //   // Request failed
    //   print('Request failed with status: ${response.statusCode}.');
    // }
    // text += response.body;
    text = text    //This time we're just splitting on any new line, then checking to see if the trimmed (to get rid of whitespace) parts in between are empty, and if they are ignoring them, and then joining the string back up.
      .split(RegExp(r'(?:\r?\n|\r)'))
      .where((s) => s.trim().length != 0)
      .join('\n');
    isUploading = false;
    setState(() {});
    if(text == '') {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('./assets/images/app_background_15.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        // decoration: const BoxDecoration(
        //     image: AssetImage(""),
        //     height: MediaQuery.of(context).size.height,
        //     width: MediaQuery.of(context).size.width, 
        //     fit: BoxFit.cover
        //   )
        // ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Builder(
                      builder: (context) => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: HexColor('#BDC2C7')
                        ),
                        onPressed: () {
                          if(isUploading)
                            return null;
                          else {
                            _choose().then((value) {
                              if(value == false)
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Text('Invalid extension!'),
                                ));
                            });
                          }
                        },
                        child: 
                          const Text(
                          'Browse Image',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Raleway',
                            fontSize: 16,      
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: HexColor('#BDC2C7')
                      ),
                      onPressed: () {
                        if(isUploading)
                          return null;
                        else 
                          _capture();
                      },
                      child: 
                        const Text(
                        'Capture Image',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Raleway',
                          fontSize: 16,      
                        ),
                      ),
                    ),
                  ],
                ),
                file == null
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: 
                        const Text(
                          'No image selected.. Browse/Click one?',
                          style: TextStyle(
                            fontFamily: 'Champagne',
                            color: Colors.white,
                            fontSize: 20,      
                          ),
                        ) 
                  )
                  : Container(
                      height: 300,
                      width: 320,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      ),
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                      child: Image.file(
                        file!,
                      ),
                    ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Builder(
                      builder: (context) => 
                      ButtonTheme(
                        height: 45.0,  
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: HexColor('#0BDDFE'),
                          ),
                          onPressed: () {
                            if(file == null){
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                duration: Duration(seconds: 2),
                                content: Text('Please select an image..'),
                              ));
                            }
                            else{
                              _upload().then((value) {
                                if(value == false) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    duration: Duration(seconds: 2),
                                    content: Text("Couldn't fetch any text.."),
                                  ));
                                }
                              });
                            }
                          },
                          child: 
                            const Text(
                            'Textify',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Raleway',
                              fontSize: 28,      
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                isUploading == false
                  ? const Text('')
                  : const Text(''),
                text == '' && isUploading == true 
                  ? Container( 
                      height: 445,
                      width: 320,
                      padding: const EdgeInsets.fromLTRB(5, 50, 5, 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ),
                    )
                  : Container( 
                      height: 445,
                      width: 320,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      ),
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Builder(
                              builder: (context) =>
                              IconButton(
                                iconSize: 20,
                                onPressed: () {
                                  if(textChanged == false || text == '') {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      duration: Duration(seconds: 2),
                                      content: Text("No text to copy.."),
                                    ));  
                                  } else {
                                    Clipboard.setData(ClipboardData(text: text));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      duration: Duration(seconds: 2),
                                      content: Text("Text copied.."),
                                    ));
                                  }
                                },
                                icon: 
                                  const Icon(
                                  Icons.content_copy,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                                child: Container(
                                  child: Text(
                                    text,
                                    style: 
                                      const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Champagne',
                                      fontSize: 22,      
                                    ),
                                  ),
                                ),
                            ),
                          ),
                        ],
                      )
                    ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
