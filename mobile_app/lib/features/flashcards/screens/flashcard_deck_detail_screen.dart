import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/flashcards/presentation/providers/flashcard_provider.dart';
import 'package:mobile_app/features/flashcards/domain/flashcard.dart';
import 'package:mobile_app/core/widgets/modern_card.dart';

class FlashcardDeckDetailScreen extends HookConsumerWidget {
  final String deckId;

  const FlashcardDeckDetailScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcardState = ref.watch(flashcardProvider);
    final deck = flashcardState.currentDeck;

    useEffect(() {
      Future.microtask(() {
        ref.read(flashcardProvider.notifier).loadDeck(deckId);
      });
      return null;
    }, [deckId]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          deck?.name ?? 'Deck',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (deck != null && deck.cards.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.play),
              onPressed: () => context.push('/home/flashcards/study/$deckId'),
              tooltip: 'Study',
            ),
        ],
      ),
      body: flashcardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : deck == null
              ? const Center(child: Text('Deck not found'))
              : _buildContent(context, ref, deck),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCardDialog(context, ref),
        icon: const Icon(LucideIcons.plus),
        label: Text(
          'Add Card',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, FlashcardDeck deck) {
    if (deck.cards.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Study button card
        Padding(
          padding: const EdgeInsets.all(16),
          child: ModernCard(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
            padding: const EdgeInsets.all(20),
            borderRadius: 20,
            child: InkWell(
              onTap: () => context.push('/home/flashcards/study/$deckId'),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.graduationCap, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Studying',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${deck.cards.length} cards to review',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.arrowRight, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        
        // Cards list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: deck.cards.length,
            itemBuilder: (context, index) {
              final card = deck.cards[index];
              return _buildCardItem(context, ref, card, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.creditCard,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No cards yet',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first flashcard to start learning',
            style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(BuildContext context, WidgetRef ref, Flashcard card, int index) {
    return Dismissible(
      key: Key(card.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(flashcardProvider.notifier).deleteCard(card.id);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ModernCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (card.timesReviewed > 0)
                    Text(
                      '${card.masteryPercent.toStringAsFixed(0)}% mastery',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Q: ${card.front}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'A: ${card.back}',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCardDialog(BuildContext context, WidgetRef ref) {
    final frontController = TextEditingController();
    final backController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Flashcard', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: frontController,
              decoration: const InputDecoration(
                labelText: 'Front (Question)',
                hintText: 'What is the capital of France?',
              ),
              maxLines: 2,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: backController,
              decoration: const InputDecoration(
                labelText: 'Back (Answer)',
                hintText: 'Paris',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (frontController.text.isNotEmpty && backController.text.isNotEmpty) {
                await ref.read(flashcardProvider.notifier).addCard(
                  deckId,
                  front: frontController.text,
                  back: backController.text,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
