// Flashcard domain models

class FlashcardDeck {
  final String id;
  final String name;
  final String? description;
  final String userId;
  final String? subjectId;
  final String? subjectName;
  final String color;
  final int cardCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastStudiedAt;
  final List<Flashcard> cards;

  FlashcardDeck({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    this.subjectId,
    this.subjectName,
    required this.color,
    this.cardCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastStudiedAt,
    this.cards = const [],
  });

  factory FlashcardDeck.fromJson(Map<String, dynamic> json) {
    return FlashcardDeck(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      userId: json['userId'] ?? '',
      subjectId: json['subjectId'],
      subjectName: json['subject']?['name'],
      color: json['color'] ?? '#6366F1',
      cardCount: (json['cards'] as List?)?.length ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      lastStudiedAt: json['lastStudiedAt'] != null ? DateTime.parse(json['lastStudiedAt']) : null,
      cards: (json['cards'] as List?)?.map((c) => Flashcard.fromJson(c)).toList() ?? [],
    );
  }
}

class Flashcard {
  final String id;
  final String front;
  final String back;
  final String deckId;
  final String difficulty;
  final int timesReviewed;
  final int timesCorrect;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    required this.deckId,
    this.difficulty = 'medium',
    this.timesReviewed = 0,
    this.timesCorrect = 0,
    this.lastReviewedAt,
    this.nextReviewAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] ?? '',
      front: json['front'] ?? '',
      back: json['back'] ?? '',
      deckId: json['deckId'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      timesReviewed: json['timesReviewed'] ?? 0,
      timesCorrect: json['timesCorrect'] ?? 0,
      lastReviewedAt: json['lastReviewedAt'] != null ? DateTime.parse(json['lastReviewedAt']) : null,
      nextReviewAt: json['nextReviewAt'] != null ? DateTime.parse(json['nextReviewAt']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  double get masteryPercent {
    if (timesReviewed == 0) return 0;
    return (timesCorrect / timesReviewed * 100).clamp(0, 100);
  }
}
