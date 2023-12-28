import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'ui/home.dart';
import 'ui/chat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Bot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      initialRoute: HomePage.routeName,
      routes: {
        HomePage.routeName: (context) => const HomePage(),
        ChatPage.routeName: (context) => const ChatPage(),
      },
    );
  }
}




/*void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VoiceRecorderPage(),
    );
  }
}

class VoiceRecorderPage extends StatefulWidget {
  @override
  _VoiceRecorderPageState createState() => _VoiceRecorderPageState();
}

class _VoiceRecorderPageState extends State<VoiceRecorderPage> {
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String _filePath = '';
  String _transcription = '';
  bool _isRecorderInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Microphone Permission'),
            content: Text('This app needs microphone access to record audio.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      await _recorder.openRecorder();
      _isRecorderInitialized = true;
      print("Recorder initialized successfully.");
    } catch (e) {
      print("Failed to initialize recorder: $e");
    }
  }

  Future<void> _startRecording() async {
    print("Attempting to start recording...");

    if (!_isRecorderInitialized) {
      print("Recorder not initialized.");
      return;
    }

    if (_isRecording) {
      print("Recorder is already recording.");
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/voice_record.wav';

    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.pcm16WAV,
    );

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) {
      return;
    }

    try {
      await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });
      print("Recording saved to: $_filePath");
      _uploadFile(_filePath);
    } catch (e) {
      // Error handling if stopping recording fails
      print("Failed to stop recording: $e");
    }
  }

  Future<void> _uploadFile(String filePath) async {
    var request = http.MultipartRequest('POST',
        Uri.parse('https://561a-102-42-222-217.ngrok-free.app/transcribe'));
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        String responseData = await response.stream.bytesToString();
        setState(() {
          _transcription = responseData;
        });
      } else {
        setState(() {
          _transcription = 'Failed with status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      // Error handling for the file upload
      print("Failed to upload file: $e");
      setState(() {
        _transcription = 'Error occurred: $e';
      });
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isRecording)
              ElevatedButton(
                onPressed: _stopRecording,
                child: Text('Stop Recording'),
              )
            else
              ElevatedButton(
                onPressed: _startRecording,
                child: Text('Start Recording'),
              ),
            SizedBox(height: 20),
            Text(_transcription),
          ],
        ),
      ),
    );
  }
}*/