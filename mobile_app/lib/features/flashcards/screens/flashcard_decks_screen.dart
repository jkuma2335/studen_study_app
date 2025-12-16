import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/flashcards/presentation/providers/flashcard_provider.dart';
import 'package:mobile_app/features/flashcards/domain/flashcard.dart';
import 'package:mobile_app/core/widgets/modern_card.dart';

class FlashcardDecksScreen extends HookConsumerWidget {
  const FlashcardDecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcardState = ref.watch(flashcardProvider);

    useEffect(() {
      Future.microtask(() {
        ref.read(flashcardProvider.notifier).loadDecks();
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flashcards',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: flashcardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : flashcardState.decks.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () => ref.read(flashcardProvider.notifier).loadDecks(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: flashcardState.decks.length,
                    itemBuilder: (context, index) {
                      final deck = flashcardState.decks[index];
                      return _buildDeckCard(context, ref, deck);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDeckDialog(context, ref),
        icon: const Icon(LucideIcons.plus),
        label: Text(
          'New Deck',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
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
              LucideIcons.layers,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No flashcard decks yet',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first deck to start learning',
            style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckCard(BuildContext context, WidgetRef ref, FlashcardDeck deck) {
    final color = _parseColor(deck.color);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ModernCard(
        padding: EdgeInsets.zero,
        borderRadius: 16,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/home/flashcards/deck/${deck.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(LucideIcons.layers, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deck.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(LucideIcons.creditCard, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${deck.cardCount} cards',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (deck.subjectName != null) ...[
                            const SizedBox(width: 12),
                            Icon(LucideIcons.bookOpen, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                deck.subjectName!,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateDeckDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Deck', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Deck Name',
            hintText: 'e.g., Biology Chapter 5',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await ref.read(flashcardProvider.notifier).createDeck(
                  name: nameController.text,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.indigo;
    }
  }
}
