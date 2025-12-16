import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_app/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:mobile_app/features/quiz/domain/quiz.dart';
import 'package:mobile_app/core/widgets/modern_card.dart';

class QuizScreen extends HookConsumerWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final quiz = quizState.currentQuiz;
    final currentIndex = useState(0);

    useEffect(() {
      Future.microtask(() {
        ref.read(quizProvider.notifier).loadQuiz(quizId);
      });
      return null;
    }, [quizId]);

    if (quizState.isLoading || quizState.isGenerating) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                quizState.isGenerating ? 'Generating quiz with AI...' : 'Loading...',
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
        ),
      );
    }

    if (quiz == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('Quiz not found')),
      );
    }

    if (quiz.isCompleted) {
      return _buildResultsScreen(context, ref, quiz);
    }

    if (quiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No questions available')),
      );
    }

    final currentQuestion = quiz.questions[currentIndex.value];
    final selectedAnswer = quizState.selectedAnswers[currentQuestion.id];
    final isLastQuestion = currentIndex.value == quiz.questions.length - 1;
    final allAnswered = quizState.selectedAnswers.length == quiz.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          quiz.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress
              Row(
                children: [
                  Text(
                    'Question ${currentIndex.value + 1}/${quiz.questions.length}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${quizState.selectedAnswers.length}/${quiz.questions.length} answered',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (currentIndex.value + 1) / quiz.questions.length,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 24),

              // Question
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQuestion.question,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Options
                      ...currentQuestion.options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        final isSelected = selectedAnswer == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref.read(quizProvider.notifier).selectAnswer(
                                currentQuestion.id,
                                index,
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.surface,
                                      border: Border.all(
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.outline,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index), // A, B, C, D
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: GoogleFonts.poppins(
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      LucideIcons.check,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Navigation
              const SizedBox(height: 16),
              Row(
                children: [
                  if (currentIndex.value > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => currentIndex.value--,
                        icon: const Icon(LucideIcons.chevronLeft, size: 18),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  if (currentIndex.value > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: selectedAnswer == null
                          ? null
                          : () async {
                              if (isLastQuestion && allAnswered) {
                                // Submit quiz
                                await ref.read(quizProvider.notifier).submitQuiz();
                              } else {
                                currentIndex.value++;
                              }
                            },
                      icon: Icon(
                        isLastQuestion && allAnswered
                            ? LucideIcons.checkCircle
                            : LucideIcons.chevronRight,
                        size: 18,
                      ),
                      label: Text(
                        isLastQuestion && allAnswered ? 'Submit Quiz' : 'Next',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen(BuildContext context, WidgetRef ref, Quiz quiz) {
    final score = quiz.score ?? 0;
    final total = quiz.totalQuestions;
    final percent = quiz.scorePercent;
    final isPassing = percent >= 70;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Score circle
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isPassing
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [Colors.orange.shade400, Colors.orange.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isPassing ? Colors.green : Colors.orange).withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percent%',
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$score / $total',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isPassing ? 'Great Job!' : 'Keep Practicing!',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPassing
                    ? 'You passed the quiz!'
                    : 'Review the explanations below to learn more.',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Questions review
              ...quiz.questions.map((question) => _buildQuestionReview(context, question)),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(quizProvider.notifier).clearQuiz();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(LucideIcons.arrowLeft),
                  label: Text(
                    'Done',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionReview(BuildContext context, QuizQuestion question) {
    final isCorrect = question.isCorrect ?? false;
    final userAnswer = question.userAnswer;
    
    return ModernCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isCorrect ? Colors.green : Colors.red).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect ? LucideIcons.check : LucideIcons.x,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question.question,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (userAnswer != null && !isCorrect) ...[
            Text(
              'Your answer: ${question.options[userAnswer]}',
              style: GoogleFonts.poppins(
                color: Colors.red.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            'Correct: ${question.options[question.correctOptionIndex]}',
            style: GoogleFonts.poppins(
              color: Colors.green.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (question.explanation != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.lightbulb,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation!,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
