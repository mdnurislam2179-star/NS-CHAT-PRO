import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const NSChatApp());
}

class NSChatApp extends StatelessWidget {
  const NSChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NS CHAT',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  String _userSpeech = "কথা বলতে নিচের মাইক বাটন চাপুন...";
  String _aiResponse = "আমি NS CHAT, আপনার ব্যক্তিগত এআই সহকারী।";

  // আপনার গুগল জেমিনাই এপিআই কি দিন
  final String _apiKey = "YOUR_GEMINI_API_KEY"AQ.Ab8RN6IjRvyQo0B2jw6wVykcSRjMoAidipvTJ9NwJ26Mo2yWqA; 

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _tts.setLanguage("bn-BD");
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() => _userSpeech = val.recognizedWords);
            if (val.finalResult) {
              setState(() => _isListening = false);
              _processCommand(_userSpeech);
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> _processCommand(String command) async {
    String lowerCmd = command.toLowerCase();

    // অ্যাপ ওপেন ও সার্চ কমান্ড নিয়ন্ত্রণ
    if (lowerCmd.contains("youtube open") || lowerCmd.contains("ইউটিউব ওপেন")) {
      _speak("ইউটিউব ওপেন করা হচ্ছে");
      _launchURL("https://www.youtube.com");
      return;
    } else if (lowerCmd.contains("facebook open") || lowerCmd.contains("ফেসবুক ওপেন")) {
      _speak("ফেসবুক ওপেন করা হচ্ছে");
      _launchURL("https://www.facebook.com");
      return;
    } else if (lowerCmd.contains("instagram open") || lowerCmd.contains("ইনস্টাগ্রাম ওপেন")) {
      _speak("ইনস্টাগ্রাম ওপেন করা হচ্ছে");
      _launchURL("https://www.instagram.com");
      return;
    } else if (lowerCmd.contains("motu patlu") || lowerCmd.contains("মটু পাতলু")) {
      _speak("ইউটিউবে মটু পাতলু প্লে করা হচ্ছে");
      _launchURL("https://www.youtube.com/results?search_query=motu+patlu");
      return;
    }

    // AI উত্তর জেনারেট
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final response = await model.generateContent([Content.text(command)]);
      String reply = response.text ?? "দুঃখিত, বুঝতে পারিনি।";
      
      setState(() {
        _aiResponse = reply;
      });
      _speak(reply);
    } catch (e) {
      setState(() {
        _aiResponse = "কোথাও সমস্যা হয়েছে: $e";
      });
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NS CHAT", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                      ),
                      child: Text("আপনি: $_userSpeech", style: const TextStyle(fontSize: 16, color: Colors.white70)),
                    ),
                    const SizedBox(height: 20),
                    // সেন্টার গোল এনিমেশন ড্যাশবোর্ড
                    Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _isListening ? Colors.greenAccent.withOpacity(0.6) : Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.graphic_eq,
                        size: 80,
                        color: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _aiResponse,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.greenAccent),
                    ),
                  ],
                ),
              ),
            ),
            FloatingActionButton.large(
              onPressed: _listen,
              backgroundColor: _isListening ? Colors.redAccent : Colors.greenAccent,
              child: Icon(_isListening ? Icons.stop : Icons.mic, size: 40, color: Colors.black),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
