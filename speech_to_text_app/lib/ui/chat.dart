import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // Add this line for path_provider
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'utils.dart';
import 'package:audio_session/audio_session.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _chatHistory = [];
  bool _isRecording = false;
  Codec _codec = Codec.aacADTS;
  String? _recordingPath;
  List<String> messages = [];
  int session = -1;
  String preference = "";
  String prefer = "";
  final TextEditingController _chatController = TextEditingController();
  int age = 25;
  String emotion = "مبسوط";
  String gender = "male";
  String name = "";
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  @override
  void initState() {
    super.initState();
    String starter = getRandomConversationStarter();
    _chatHistory.add({
      "time": DateTime.now(),
      "isshown": false,
      "message": getGenderSpecificSentence(starter, gender),
      "isSender": false,
    });
    initRecorder();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status == PermissionStatus.granted) {
      await recorder.openRecorder();
      isRecorderReady = true;
    }
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  void updateConversation(String text) {
    setState(() {
      _chatHistory.add({
        "time": DateTime.now(),
        "isshown": false,
        "message": text,
        "isSender": true,
      });
      if (session == 0 || session == -1) {
        if (session == -1) {
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message": "ممكن اعرف اسمك الاول؟",
            "isSender": false,
          });
          session = 0;
          return;
        }
        if (extractName(text) == null) {
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message":
                getGenderSpecificSentence('مسمعتش اسمك، اسمك ايه؟', gender),
            "isSender": false,
          });
          return;
        }
        name = extractName(text)!;
        emotion += gender == "female" ? "ة" : "";
        String greeting =
            "ازيك يا $name! بما انك $emotion. تحب تسمع اغاني ولا تتفرج على فيلم ولا تلعب ولا تخرج؟";
        _chatHistory.add({
          "time": DateTime.now(),
          "isshown": false,
          "message": getGenderSpecificSentence(greeting, gender),
          "isSender": false,
        });
        session = 2;
        return;
      }
      if (session == 2) {
        preference = text;
        prefer = preference;
        String? suggestion =
            getEntertainmentSuggestion(age, emotion, preference, gender);
        if (suggestion!.startsWith("جرب تاني") ||
            suggestion.startsWith("جربي تاني")) {
          suggestion = getRandomTryAgainMessage();
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message": getGenderSpecificSentence(suggestion, gender),
            "isSender": false,
          });
          return;
        } else {
          String feedbackQuestion = getRandomFeedback(preference, gender, age);
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message": feedbackQuestion,
            "isSender": false,
          });
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message": suggestion,
            "isSender": false,
          });
          session = 3;
          return;
        }
      }
      if (session == 3) {
        preference = text;
        if (RegExp(r'(كويس|تمام|حلو|شكر|شكرا|ماشي|اه)').hasMatch(preference)) {
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message": getGenderSpecificSentence(
                'عاوز اقتراح تاني لنشاط غير ده؟', gender),
            "isSender": false,
          });
          prefer = "";
          session = 4;
          return;
        } else {
          String? suggestion =
              getEntertainmentSuggestion(age, emotion, prefer, gender);
          String feedbackQuestion = getRandomFeedback(prefer, gender, age);
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message": "$suggestion، $feedbackQuestion",
            "isSender": false,
          });
          return;
        }
      }
      if (session == 4) {
        String continuePattern = r'(اه|نعم|يس|أكيد)';
        if (RegExp(continuePattern).hasMatch(text)) {
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message":
                getGenderSpecificSentence(getRandomQuestion(gender), gender),
            "isSender": false,
          });
          session = 2;
          return;
        } else {
          _chatHistory.add({
            "time": DateTime.now(),
            "isshown": false,
            "message": getGenderSpecificSentence(
                'تشرفنا بالكلام معاك، يوم سعيد!', gender),
            "isSender": false,
          });
          session = 0;
          return;
        }
      }
    });
  }

  @override
  void dispose() {
    if (recorder.isRecording) {
      recorder.stopRecorder();
    }
    recorder.closeRecorder();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void handleUserInput(String input) {
    // ignore: avoid_print
    print("aaaaaaaaaaaaa session : $session");
    updateConversation(input);
    _scrollToEnd();
    _chatController.clear();
  }

  Future<void> _handleRecord() async {
    try {
      if (_isRecording) {
        // Check if it is already recording
        final path = await recorder.stopRecorder();
        setState(() {
          _isRecording = false;
          _recordingPath = path;
        });
        print('Recording stopped and saved to: $_recordingPath');
        if (_recordingPath != null) {
          await sendFile(_recordingPath!);
        }
      } else {
        // Ensure permissions are granted
        final status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          throw 'Microphone permission not granted';
        }
        final dir = await getApplicationDocumentsDirectory();
        _recordingPath =
            '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

        await recorder.startRecorder(toFile: _recordingPath);
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      print('Failed to record: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> sendFile(String filePath) async {
    var uri = Uri.parse('https://7072-102-43-79-150.ngrok-free.app/transcribe');
    var request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        print('File successfully sent!');
        var data = json.decode(response.body);
        var transcription = data['transcription'];
        String combinedTranscription = transcription.join(" ");
        handleUserInput(combinedTranscription);
      } else {
        print('Failed to send file, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Chat",
          style: GoogleFonts.aboreto(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 160,
            child: ListView.builder(
              itemCount: _chatHistory.length,
              shrinkWrap: false,
              controller: _scrollController,
              padding: EdgeInsets.only(top: 10, bottom: 100),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                var message = _chatHistory[index];
                var time = message["time"] as DateTime;
                String formattedTime = DateFormat('hh:mm a').format(time);
                bool isBotMessage = !_chatHistory[index]["isSender"];
                return Container(
                  padding:
                      EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                  child: Align(
                    alignment:
                        isBotMessage ? Alignment.topLeft : Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        color: isBotMessage ? Colors.white : Color(0xFFF69170),
                      ),
                      padding: EdgeInsets.all(16),
                      child: isBotMessage
                          ? FutureBuilder(
                              future: message["isshown"]
                                  ? Future.value()
                                  : Future.delayed(Duration(seconds: 2)),
                              builder: (context, snapshot) {
                                if (message["isshown"] ||
                                    snapshot.connectionState ==
                                        ConnectionState.done) {
                                  message["isshown"] = true;
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset('assets/bot.png', width: 37),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          message["message"],
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          formattedTime,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: const Color.fromARGB(
                                                255, 219, 218, 218),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  // While waiting, show the typing indicator
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset('assets/bot.png', width: 37),
                                      SizedBox(width: 8),
                                      typingIndicator(),
                                    ],
                                  );
                                }
                              },
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    message["message"],
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: const Color.fromARGB(
                                          255, 219, 218, 218),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          border: GradientBoxBorder(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFF69170),
                                  Color(0xFF7D96E6),
                                ]),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                              onPressed: () async {
                                await _handleRecord();
                              },
                            ),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Type a message",
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(8.0),
                                ),
                                controller: _chatController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          if (_chatController.text.isNotEmpty) {
                            handleUserInput(_chatController.text);
                            _chatController.clear();
                          }
                        });
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      padding: const EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFF69170),
                                Color(0xFF7D96E6),
                              ]),
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        ),
                        child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 88.0, minHeight: 36.0),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                            )),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget typingIndicator() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(3, (index) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 2),
        height: 10,
        width: 10,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      );
    }),
  );
}
