import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../data/bot_faq.dart';
import '../models/property.dart';

/// Global Pando state: the sticky-note text, auto-speak/mute/replay status,
/// and the single-turn "ask Pando" answer logic. There is no chat history —
/// every screen calls [speak] on load, and [ask] resolves an answer that
/// replaces the note text and is spoken again.
class PandoProvider extends ChangeNotifier {
  bool noteVisible = true;
  String noteText = '';
  bool isSpeaking = false;

  /// The community last viewed/searched this session — used to vary the
  /// Landing screen's welcome note on return visits.
  String? lastCommunity;

  /// The property currently open on the Details screen, if any. Follow-up
  /// questions asked while here are answered from this object first.
  Property? currentProperty;

  void setCurrentProperty(Property? property) {
    currentProperty = property;
    if (property != null) lastCommunity = property.community;
  }

  void rememberCommunity(String community) {
    lastCommunity = community;
  }

  final FlutterTts _tts = FlutterTts();

  PandoProvider() {
    _tts.setCompletionHandler(_finishSpeaking);
    _tts.setCancelHandler(_finishSpeaking);
    _tts.setErrorHandler((_) => _finishSpeaking());
  }

  void _finishSpeaking() {
    if (!isSpeaking) return;
    isSpeaking = false;
    notifyListeners();
  }

  /// Speaks [text] in the sticky note: sets it as the current note, marks
  /// speaking as active, and clears it after a duration proportional to
  /// length (standing in for real TTS playback).
  Future<void> speak(String text) async {
    await _tts.stop();
    noteText = text;
    noteVisible = true;
    isSpeaking = true;
    notifyListeners();

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.46);
    await _tts.setVolume(1.0);
    await _tts.speak(text);
  }

  /// Speaker icon behavior: mutes mid-speech, or replays the current note.
  Future<void> toggleSpeaker() async {
    if (isSpeaking) {
      await _tts.stop();
      isSpeaking = false;
      notifyListeners();
    } else if (noteText.isNotEmpty) {
      await speak(noteText);
    }
  }

  Future<void> dismissNote() async {
    await _tts.stop();
    isSpeaking = false;
    noteVisible = false;
    notifyListeners();
  }

  void showNote() {
    noteVisible = true;
    if (!isSpeaking && noteText.isNotEmpty) unawaited(speak(noteText));
    notifyListeners();
  }

  /// Resolves an answer to a free-text question asked via the ask box and
  /// speaks it through the sticky note (property context -> search intent
  /// -> FAQ -> fallback).
  Future<void> ask(String question, List<Property> allProperties) async {
    final lower = question.toLowerCase();
    final fromProperty = currentProperty != null ? _answerFromProperty(lower, currentProperty!) : null;
    await speak(fromProperty ?? _resolveAnswer(lower, allProperties));
  }

  /// Answers a question about the property currently open on the Details
  /// screen, straight from that property's own data.
  String? _answerFromProperty(String lower, Property p) {
    if (lower.contains('furnish')) {
      return "${p.title} comes ${p.furnishing.toLowerCase()}.";
    }
    if (lower.contains('bedroom') || lower.contains('bed')) {
      return "${p.title} has ${p.bedrooms} bedrooms.";
    }
    if (lower.contains('bathroom') || lower.contains('bath')) {
      return "${p.title} has ${p.bathrooms} bathrooms.";
    }
    if (lower.contains('price') || lower.contains('cost') || lower.contains('much')) {
      return "${p.title} is priced at ${p.priceFormatted}.";
    }
    if (lower.contains('size') || lower.contains('sq') || lower.contains('area')) {
      return "${p.title} spans ${p.areaSqft} square feet.";
    }
    if (lower.contains('amenit') || lower.contains('feature')) {
      return "${p.title} comes with ${p.amenities.take(4).join(', ')}.";
    }
    if (lower.contains('view') || lower.contains('highlight') || lower.contains('special')) {
      return p.highlight.isNotEmpty ? p.highlight : "It offers ${p.standoutReason}.";
    }
    if (lower.contains('rent') || lower.contains('buy') || lower.contains('sale')) {
      final purpose = p.purpose == PropertyPurpose.rent ? 'available for rent' : 'available for sale';
      return "${p.title} is $purpose at ${p.priceFormatted}.";
    }
    return null;
  }

  String _resolveAnswer(String lower, List<Property> allProperties) {
    final bedroomMatch = RegExp(r'(\d+)\s*(bed|bedroom)').firstMatch(lower);
    final wantsBuy = lower.contains('buy');
    final wantsRent = lower.contains('rent');
    final wantsOffPlan =
        lower.contains('off-plan') || lower.contains('off plan');

    if (bedroomMatch != null ||
        wantsBuy ||
        wantsRent ||
        wantsOffPlan ||
        lower.contains('propert') ||
        lower.contains('villa') ||
        lower.contains('apartment')) {
      var results = allProperties.toList();
      if (wantsBuy) {
        results = results
            .where((p) => p.purpose == PropertyPurpose.buy)
            .toList();
      }
      if (wantsRent) {
        results = results
            .where((p) => p.purpose == PropertyPurpose.rent)
            .toList();
      }
      if (wantsOffPlan) {
        results = results
            .where((p) => p.purpose == PropertyPurpose.offPlan)
            .toList();
      }
      if (bedroomMatch != null) {
        final beds = int.parse(bedroomMatch.group(1)!);
        results = results.where((p) => p.bedrooms == beds).toList();
      }
      if (results.isEmpty) {
        return "I couldn't find a match for that yet. Try a different bedroom count or purpose.";
      }
      final top = results.first;
      return "I found ${results.length} ${results.length == 1 ? 'property' : 'properties'} matching that. "
          "Top pick: ${top.title} in ${top.community} for ${top.priceFormatted}.";
    }

    final faqAnswer = matchFaq(lower);
    if (faqAnswer != null) return faqAnswer;

    return "I couldn't find an exact answer for that. Would you like to talk to one of our agents?";
  }

  @override
  void dispose() {
    unawaited(_tts.stop());
    super.dispose();
  }
}
