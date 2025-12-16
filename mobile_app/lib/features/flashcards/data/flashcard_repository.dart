import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/features/flashcards/domain/flashcard.dart';

class FlashcardRepository {
  final ApiClient _apiClient;

  FlashcardRepository(this._apiClient);

  // ============= DECK OPERATIONS =============

  Future<List<FlashcardDeck>> getDecks() async {
    final response = await _apiClient.get('/flashcards/decks');
    return (response.data as List)
        .map((json) => FlashcardDeck.fromJson(json))
        .toList();
  }

  Future<FlashcardDeck> getDeck(String id) async {
    final response = await _apiClient.get('/flashcards/decks/$id');
    return FlashcardDeck.fromJson(response.data);
  }

  Future<FlashcardDeck> createDeck({
    required String name,
    String? description,
    String? subjectId,
    String? color,
  }) async {
    final response = await _apiClient.post('/flashcards/decks', data: {
      'name': name,
      if (description != null) 'description': description,
      if (subjectId != null) 'subjectId': subjectId,
      if (color != null) 'color': color,
    });
    return FlashcardDeck.fromJson(response.data);
  }

  Future<FlashcardDeck> updateDeck(String id, {
    String? name,
    String? description,
    String? subjectId,
    String? color,
  }) async {
    final response = await _apiClient.put('/flashcards/decks/$id', data: {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (subjectId != null) 'subjectId': subjectId,
      if (color != null) 'color': color,
    });
    return FlashcardDeck.fromJson(response.data);
  }

  Future<void> deleteDeck(String id) async {
    await _apiClient.delete('/flashcards/decks/$id');
  }

  // ============= CARD OPERATIONS =============

  Future<Flashcard> addCard(String deckId, {
    required String front,
    required String back,
  }) async {
    final response = await _apiClient.post('/flashcards/decks/$deckId/cards', data: {
      'front': front,
      'back': back,
    });
    return Flashcard.fromJson(response.data);
  }

  Future<List<Flashcard>> getDueCards(String deckId) async {
    final response = await _apiClient.get('/flashcards/decks/$deckId/due');
    return (response.data as List)
        .map((json) => Flashcard.fromJson(json))
        .toList();
  }

  Future<Flashcard> updateCard(String cardId, {
    String? front,
    String? back,
  }) async {
    final response = await _apiClient.put('/flashcards/cards/$cardId', data: {
      if (front != null) 'front': front,
      if (back != null) 'back': back,
    });
    return Flashcard.fromJson(response.data);
  }

  Future<void> deleteCard(String cardId) async {
    await _apiClient.delete('/flashcards/cards/$cardId');
  }

  Future<Flashcard> reviewCard(String cardId, {
    required String difficulty,
    bool? correct,
  }) async {
    final response = await _apiClient.post('/flashcards/cards/$cardId/review', data: {
      'difficulty': difficulty,
      if (correct != null) 'correct': correct,
    });
    return Flashcard.fromJson(response.data);
  }
}
