import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/features/flashcards/data/flashcard_repository.dart';
import 'package:mobile_app/features/flashcards/domain/flashcard.dart';

class FlashcardState {
  final bool isLoading;
  final String? error;
  final List<FlashcardDeck> decks;
  final FlashcardDeck? currentDeck;

  FlashcardState({
    this.isLoading = false,
    this.error,
    this.decks = const [],
    this.currentDeck,
  });

  FlashcardState copyWith({
    bool? isLoading,
    String? error,
    List<FlashcardDeck>? decks,
    FlashcardDeck? currentDeck,
  }) {
    return FlashcardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      decks: decks ?? this.decks,
      currentDeck: currentDeck ?? this.currentDeck,
    );
  }
}

class FlashcardNotifier extends StateNotifier<FlashcardState> {
  final FlashcardRepository _repository;

  FlashcardNotifier(this._repository) : super(FlashcardState());

  Future<void> loadDecks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final decks = await _repository.getDecks();
      state = state.copyWith(isLoading: false, decks: decks);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadDeck(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final deck = await _repository.getDeck(id);
      state = state.copyWith(isLoading: false, currentDeck: deck);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<FlashcardDeck?> createDeck({
    required String name,
    String? description,
    String? subjectId,
    String? color,
  }) async {
    try {
      final deck = await _repository.createDeck(
        name: name,
        description: description,
        subjectId: subjectId,
        color: color,
      );
      state = state.copyWith(decks: [...state.decks, deck]);
      return deck;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> deleteDeck(String id) async {
    try {
      await _repository.deleteDeck(id);
      state = state.copyWith(
        decks: state.decks.where((d) => d.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<Flashcard?> addCard(String deckId, {required String front, required String back}) async {
    try {
      final card = await _repository.addCard(deckId, front: front, back: back);
      // Refresh the current deck if it's the one we added to
      if (state.currentDeck?.id == deckId) {
        await loadDeck(deckId);
      }
      return card;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      await _repository.deleteCard(cardId);
      // Refresh current deck
      if (state.currentDeck != null) {
        await loadDeck(state.currentDeck!.id);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<Flashcard?> reviewCard(String cardId, {required String difficulty, bool? correct}) async {
    try {
      return await _repository.reviewCard(cardId, difficulty: difficulty, correct: correct);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  return FlashcardRepository(ApiClient());
});

final flashcardProvider = StateNotifierProvider<FlashcardNotifier, FlashcardState>((ref) {
  return FlashcardNotifier(ref.read(flashcardRepositoryProvider));
});
