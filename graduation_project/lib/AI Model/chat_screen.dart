import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For defaultTargetPlatform
import 'package:graduation_project/AI%20Model/chat_api.dart';
import 'package:graduation_project/AI%20Model/models/Message.dart';
import 'package:graduation_project/utils/auth_guard.dart'; // ✅ added
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _showChatInput = false;
  bool _collectingRoomInfo = false;
  bool _isTyping = false;
  bool _canAccess = false;
  Map<String, dynamic> _roomQuery = {};
  int _roomStep = 0;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final allowed = await AuthGuard.checkAccess(context: context);
    if (!mounted) return;

    if (!allowed) {
      Navigator.pop(context);
    } else {
      setState(() {
        _canAccess = true;
      });
    }
  }

  String getBaseUrl() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:5000";
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return "http://127.0.0.1:5000";
    }
    return "http://127.0.0.1:5000";
  }

  final List<Map<String, dynamic>> _initialOptions = [
    {"label": "What is StudentHousing Hub?", "icon": Icons.info},
    {"label": "Search Rooms with AI Model", "icon": Icons.search},
    {"label": "Chat with AI", "icon": Icons.chat},
  ];

  void _handleOptionSelected(String option) {
    if (option == "What is StudentHousing Hub?") {
      _addBotMessage("StudentHub helps students find rooms near universities easily by filtering preferences like price, type, and location.");
    } else if (option == "Search Rooms with AI Model") {
      setState(() {
        _collectingRoomInfo = true;
        _roomQuery = {};
        _roomStep = 0;
      });
      _askNextRoomStep();
    } else if (option == "Chat with AI") {
      setState(() {
        _showChatInput = true;
      });
    }
  }

  void _askNextRoomStep() async {
    if (_roomStep == 0) {
      final response = await http.get(Uri.parse("${getBaseUrl()}/universities"));
      if (response.statusCode == 200) {
        List<dynamic> universities = jsonDecode(response.body);
        _addBotMessage("Which university are you looking near?", buttons: universities.cast<String>());
      } else {
        _addBotMessage("Couldn't load university list, please type it:");
      }
    } else if (_roomStep == 1) {
      _addBotMessage("Enter minimum price:");
    } else if (_roomStep == 2) {
      _addBotMessage("Enter maximum price:");
    } else if (_roomStep == 3) {
      _addBotMessage("What resident type do you prefer?", buttons: ["Male", "Female"]);
    } else if (_roomStep == 4) {
      _addBotMessage("What room size do you prefer?", buttons: ["Small", "Medium", "Large"]);
    }
  }

  void _handleRoomResponse(String text) async {
    switch (_roomStep) {
      case 0:
        _roomQuery['university'] = text;
        break;
      case 1:
        _roomQuery['min_price'] = int.tryParse(text);
        break;
      case 2:
        _roomQuery['max_price'] = int.tryParse(text);
        break;
      case 3:
        _roomQuery['resident_type'] = text.toLowerCase();
        break;
      case 4:
        _roomQuery['room_size'] = text.toLowerCase();
        break;
    }
    _roomStep++;

    if (_roomStep < 5) {
      _askNextRoomStep();
    } else {
      setState(() {
        _collectingRoomInfo = false;
      });
      await _searchRoomsWithModel();
    }
  }

  int _convertRoomSize(String size) {
    switch (size.toLowerCase()) {
      case 'small':
        return 1;
      case 'medium':
        return 2;
      case 'large':
        return 3;
      default:
        return 2;
    }
  }

  Future<void> _searchRoomsWithModel() async {
    _addBotMessage("Searching rooms based on your preferences...");
    try {
      final response = await http.post(
        Uri.parse("${getBaseUrl()}/recommend"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "university": _roomQuery['university'],
          "min_price": _roomQuery['min_price'],
          "max_price": _roomQuery['max_price'],
          "gender": _roomQuery['resident_type'],
          "room_size": _convertRoomSize(_roomQuery['room_size']),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isEmpty) {
          _addBotMessage("No rooms matched your preferences.");
        } else {
          String formatted = data.map<String>((room) =>
              "- ${room['Title']} | ${room['UniversityName']} | ${room['Price']} EGP | ${room['Gender']} | ${room['No_Beds']} beds").join("\n");
          _addBotMessage("Found ${data.length} room(s):\n$formatted");
        }
      } else {
        _addBotMessage("Error fetching rooms: ${response.statusCode}\n${response.body}");
      }
    } catch (e) {
      _addBotMessage("Network error: $e");
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _controller.clear();
    _addUserMessage(text);

    if (_collectingRoomInfo) {
      _handleRoomResponse(text);
    } else {
      _getChatbotResponse(text);
    }
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.insert(0, Message(text: text, isUser: true));
    });
  }

  void _addBotMessage(String text, {List<String>? buttons}) {
    setState(() {
      _isTyping = false;
      _messages.insert(0, Message(text: text, isUser: false, buttons: buttons));
    });
  }

  Future<void> _getChatbotResponse(String text) async {
    setState(() {
      _isTyping = true;
    });
    final botResponse = await ChatApi.getBotResponse(text);
    _addBotMessage(botResponse);
  }

  void _goBackToMenu() {
    setState(() {
      _showChatInput = false;
      _collectingRoomInfo = false;
      _messages.clear();
      _controller.clear();
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_canAccess) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 600;
    const Color primaryColor = Color(0xFF519FEE);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Chatbot"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: primaryColor),
        foregroundColor: primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          if (!_showChatInput && !_collectingRoomInfo)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _initialOptions.map((option) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              onTap: () => _handleOptionSelected(option['label']),
                              leading: Icon(option['icon'], color: primaryColor),
                              title: Text(option['label'], style: TextStyle(color: primaryColor)),
                              tileColor: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : Wrap(
                      spacing: 8.0,
                      children: _initialOptions.map((option) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextButton.icon(
                            onPressed: () => _handleOptionSelected(option['label']),
                            icon: Icon(option['icon'], color: primaryColor),
                            label: Text(option['label'], style: TextStyle(color: primaryColor)),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          if (_showChatInput || _collectingRoomInfo)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: TextButton.icon(
                  onPressed: _goBackToMenu,
                  icon: Icon(Icons.arrow_back, color: primaryColor),
                  label: Text("Back to Menu", style: TextStyle(color: primaryColor)),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (_isTyping && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const CircularProgressIndicator(strokeWidth: 2),
                        const SizedBox(width: 12),
                        const Text("Typing..."),
                      ],
                    ),
                  );
                }

                final Message message = _messages[_isTyping ? index - 1 : index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.isUser ? primaryColor : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(color: message.isUser ? Colors.white : Colors.black87),
                        ),
                      ),
                      if (message.buttons != null)
                        Wrap(
                          children: message.buttons!.map((button) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8, right: 8),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryColor,
                                  side: BorderSide(color: primaryColor),
                                ),
                                onPressed: () {
                                  _addUserMessage(button);
                                  _handleRoomResponse(button);
                                },
                                child: Text(button),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(height: 1.0),
          if (_showChatInput || _collectingRoomInfo)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              color: Theme.of(context).cardColor,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _handleSubmitted,
                      decoration: InputDecoration.collapsed(hintText: "Type your message"),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: primaryColor),
                    onPressed: () => _handleSubmitted(_controller.text),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
