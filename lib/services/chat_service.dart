import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/firestore_service.dart';

class ChatService {
  final String _apiKey = "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";
  final String _apiUrl = "https://api.groq.com/openai/v1/chat/completions";
  final String _model = "llama-3.3-70b-versatile";

  final List<Map<String, String>> _messages = [];
  bool isReady = false;

  ChatService();

  Future<void> initializeContext() async {
    final firestore = FirestoreService();
    
    // Fetch currently available items
    final trips = await firestore.getPlannedTrips().first;
    final destinations = await firestore.getDestinations().first;
    final workshops = await firestore.getWorkshops().first;

    String catalogContext = "Available Trips:\n";
    for (var trip in trips) {
      catalogContext += "- ${trip.title} (${trip.price} EGP)\n";
    }

    catalogContext += "\nAvailable Destinations:\n";
    for (var dest in destinations) {
      catalogContext += "- ${dest.name}\n";
    }

    catalogContext += "\nAvailable Workshops:\n";
    for (var ws in workshops) {
      catalogContext += "- ${ws.title} (${ws.price} EGP)\n";
    }

    _messages.clear();
    _messages.add({
      "role": "system",
      "content": "You are 'Trippy', the friendly travel assistant for the Trippies app. "
          "You help female solo travelers explore Giza and Cairo, Egypt. "
          "You only answer travel-related questions about destinations, trips, "
          "workshops, safety tips, local food, culture, and activities in Giza and Cairo. "
          "If someone asks a non-travel question, politely redirect them. "
          "Keep responses concise (2-3 short paragraphs max), warm, and helpful. "
          "Use emojis occasionally for personality.\n\n"
          "Here is the current catalog of what we offer in the app. "
          "Suggest these specific items only when they match the user's input:\n\n$catalogContext"
    });
    
    isReady = true;
  }

  Stream<String> sendMessageStream(String text) async* {
    _messages.add({"role": "user", "content": text});

    final request = http.Request('POST', Uri.parse(_apiUrl));
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    });

    request.body = jsonEncode({
      "model": _model,
      "messages": _messages,
      "stream": true,
    });

    try {
      final response = await http.Client().send(request);
      
      if (response.statusCode != 200) {
        final err = await response.stream.bytesToString();
        yield "API Error ${response.statusCode}: $err";
        return;
      }

      String fullResponse = '';

      // Stream the response and parse OpenAI-compatible SSE format
      await for (var chunk in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (chunk.startsWith('data: ')) {
          final data = chunk.substring(6);
          if (data == '[DONE]') break;
          
          try {
            final json = jsonDecode(data);
            final content = json['choices'][0]['delta']['content'];
            if (content != null) {
              fullResponse += content;
              yield content; // yield just the tiny chunk of text so UI can stream it
            }
          } catch (_) {
            // ignore malformed JSON or empty deltas
          }
        }
      }

      // Save the complete response to the message history so the bot remembers the context
      _messages.add({"role": "assistant", "content": fullResponse});

    } catch (e) {
      yield "Sorry, I'm having trouble connecting right now. Please try again later.";
    }
  }

  Future<void> resetChat() async {
    isReady = false;
    await initializeContext();
  }
}
