import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

void main() {
  Gemini.init(apiKey: 'YOUR_GEMINI_API_KEY'); // replace with your key
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gemini Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  final ChatUser currentUser = ChatUser(id: '0', firstName: "User");
  final ChatUser geminiUser = ChatUser(
    id: '1',
    firstName: 'Gemini',
    profileImage:
        'https://i.pinimg.com/1200x/d1/94/ae/d194aeea8bb120c531a9d4d9ef6622d4.jpg',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Gemini Try'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: DashChat(
        currentUser: currentUser,
        messages: messages,
        onSend: _sendMessage,
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    final String question = chatMessage.text;

    try {
      gemini.streamGenerateContent(question).listen((event) {
        final String response = event.output ?? "No response";

        final ChatMessage message = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: response,
        );

        setState(() {
          messages = [message, ...messages];
        });
      });
    } catch (e) {
      print('Gemini error!: $e');
    }
  }
}
