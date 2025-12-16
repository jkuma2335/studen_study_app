import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_app/features/flashcards/presentation/providers/flashcard_provider.dart';
import 'package:mobile_app/features/flashcards/domain/flashcard.dart';

class FlashcardStudyScreen extends HookConsumerWidget {
  final String deckId;

  const FlashcardStudyScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcardState = ref.watch(flashcardProvider);
    final deck = flashcardState.currentDeck;
    final currentIndex = useState(0);
    final isFlipped = useState(false);
    final completed = useState(0);
    final flipController = useAnimationController(duration: const Duration(milliseconds: 400));

    useEffect(() {
      Future.microtask(() {
        ref.read(flashcardProvider.notifier).loadDeck(deckId);
      });
      return null;
    }, [deckId]);

    if (flashcardState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (deck == null || deck.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study')),
        body: const Center(child: Text('No cards to study')),
      );
    }

    final cards = deck.cards;
    final isComplete = currentIndex.value >= cards.length;

    if (isComplete) {
      return _buildCompletionScreen(context, completed.value, cards.length);
    }

    final currentCard = cards[currentIndex.value];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '${currentIndex.value + 1} / ${cards.length}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (currentIndex.value + 1) / cards.length,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 32),

              // Flashcard
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (isFlipped.value) {
                      flipController.reverse();
                    } else {
                      flipController.forward();
                    }
                    isFlipped.value = !isFlipped.value;
                  },
                  child: AnimatedBuilder(
                    animation: flipController,
                    builder: (context, child) {
                      final angle = flipController.value * math.pi;
                      final isFront = angle < math.pi / 2;
                      
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: isFront
                            ? _buildCardSide(
                                context,
                                'Question',
                                currentCard.front,
                                isQuestion: true,
                              )
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(math.pi),
                                child: _buildCardSide(
                                  context,
                                  'Answer',
                                  currentCard.back,
                                  isQuestion: false,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tap to flip hint
              if (!isFlipped.value)
                Text(
                  'Tap to reveal answer',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              else ...[
                Text(
                  'How well did you know this?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDifficultyButton(
                        context,
                        'Hard',
                        Colors.red,
                        LucideIcons.frown,
                        () async {
                          HapticFeedback.mediumImpact();
                          await ref.read(flashcardProvider.notifier).reviewCard(
                            currentCard.id,
                            difficulty: 'hard',
                            correct: false,
                          );
                          _nextCard(currentIndex, isFlipped, flipController, cards.length);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDifficultyButton(
                        context,
                        'Medium',
                        Colors.orange,
                        LucideIcons.meh,
                        () async {
                          HapticFeedback.mediumImpact();
                          await ref.read(flashcardProvider.notifier).reviewCard(
                            currentCard.id,
                            difficulty: 'medium',
                            correct: true,
                          );
                          completed.value++;
                          _nextCard(currentIndex, isFlipped, flipController, cards.length);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDifficultyButton(
                        context,
                        'Easy',
                        Colors.green,
                        LucideIcons.smile,
                        () async {
                          HapticFeedback.mediumImpact();
                          await ref.read(flashcardProvider.notifier).reviewCard(
                            currentCard.id,
                            difficulty: 'easy',
                            correct: true,
                          );
                          completed.value++;
                          _nextCard(currentIndex, isFlipped, flipController, cards.length);
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardSide(BuildContext context, String label, String content, {required bool isQuestion}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isQuestion
              ? [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                ]
              : [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.85),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isQuestion
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary)
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String label,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.15),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _nextCard(
    ValueNotifier<int> currentIndex,
    ValueNotifier<bool> isFlipped,
    AnimationController flipController,
    int totalCards,
  ) {
    flipController.reset();
    isFlipped.value = false;
    currentIndex.value++;
  }

  Widget _buildCompletionScreen(BuildContext context, int correct, int total) {
    final percent = total > 0 ? (correct / total * 100).round() : 0;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.trophy,
                  size: 64,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Session Complete!',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You reviewed $total cards',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$correct correct ($percent%)',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(LucideIcons.arrowLeft),
                label: Text(
                  'Back to Deck',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
