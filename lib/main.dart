import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:mlprojet2024/firebase_options.dart';
import 'package:file_picker/file_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //variable
  TextEditingController phraseTapped = TextEditingController();
  String laLangue = "";
  LanguageIdentifier identifiedLanguage =
      LanguageIdentifier(confidenceThreshold: 0.4);
  OnDeviceTranslator translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.french,
      targetLanguage: TranslateLanguage.spanish);
  Uint8List? images;
  ImageLabeler imageLabeler =
      ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));

  //méthode
  checkLangue() async {
    if (phraseTapped != "") {
      String l = await identifiedLanguage.identifyLanguage(phraseTapped.text);
      setState(() {
        laLangue = l;
      });
    }
  }

  checkMultipleLangue() async {
    if (phraseTapped != "") {
      List possibleLang =
          await identifiedLanguage.identifyPossibleLanguages(phraseTapped.text);
      for (IdentifiedLanguage lesLang in possibleLang) {
        String l =
            "voici la langue ${lesLang.languageTag} avec une confiance de ${(lesLang.confidence) * 100} % \n";
        setState(() {
          laLangue = l;
        });
      }
    }
  }

  translate() async {
    if (phraseTapped != null) {
      String l = await translator.translateText(phraseTapped.text);
      setState(() {
        laLangue = l;
      });
    }
  }

  pickImage() async {
    String l = "";
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
    );
    if (result != null) {
      setState(() {
        images = result.files.first.bytes;
      });
      InputImage inputImage = InputImage.fromBytes(
          bytes: images!,
          metadata: InputImageMetadata(
              size: const Size(250, 250),
              rotation: InputImageRotation.rotation0deg,
              format: InputImageFormat.bgra8888,
              bytesPerRow: 0));
      List labels = await imageLabeler.processImage(inputImage);
      for (ImageLabel label in labels) {
        l = "je constate un ${label.label} avec une confiance de ${label.confidence * 100} %\n";
      }
      setState(() {
        laLangue = l;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: phraseTapped,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                checkLangue();
              },
              child: const Text("Déterminer la langue"),
            ),
            ElevatedButton(
              onPressed: () {
                checkMultipleLangue();
              },
              child: Text("Multiple langue"),
            ),
            ElevatedButton(
              onPressed: () {
                translate();
              },
              child: Text("Traduire"),
            ),
            ElevatedButton(
              onPressed: () {
                pickImage();
              },
              child: Text("Click image"),
            ),
            (images != null) ? Image.memory(images!) : Container(),
            Spacer(),
            Text(laLangue)
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
