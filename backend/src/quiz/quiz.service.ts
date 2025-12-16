import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Quiz } from './entities/quiz.entity';
import { QuizQuestion } from './entities/quiz-question.entity';
import { AiService } from './ai.service';
import { GenerateQuizDto, SubmitQuizDto } from './dto/quiz.dto';

@Injectable()
export class QuizService {
    constructor(
        @InjectRepository(Quiz)
        private quizRepository: Repository<Quiz>,
        @InjectRepository(QuizQuestion)
        private questionRepository: Repository<QuizQuestion>,
        private aiService: AiService,
    ) { }

    async generateQuiz(userId: string, dto: GenerateQuizDto): Promise<Quiz> {
        const numQuestions = dto.numQuestions || 5;

        // Generate questions using AI
        const generatedQuestions = await this.aiService.generateQuizFromContent(
            dto.content,
            numQuestions,
        );

        // Create quiz
        const quiz = this.quizRepository.create({
            title: dto.title || 'AI Generated Quiz',
            userId,
            noteId: dto.noteId,
            subjectId: dto.subjectId,
            totalQuestions: generatedQuestions.length,
        });

        const savedQuiz = await this.quizRepository.save(quiz);

        // Create questions
        const questions = generatedQuestions.map((q) =>
            this.questionRepository.create({
                question: q.question,
                options: q.options,
                correctOptionIndex: q.correctOptionIndex,
                explanation: q.explanation,
                quizId: savedQuiz.id,
            }),
        );

        await this.questionRepository.save(questions);

        return this.getQuiz(userId, savedQuiz.id);
    }

    async getQuiz(userId: string, quizId: string): Promise<Quiz> {
        const quiz = await this.quizRepository.findOne({
            where: { id: quizId },
            relations: ['questions'],
        });

        if (!quiz) {
            throw new NotFoundException('Quiz not found');
        }

        if (quiz.userId !== userId) {
            throw new ForbiddenException('Access denied');
        }

        return quiz;
    }

    async getQuizHistory(userId: string): Promise<Quiz[]> {
        return this.quizRepository.find({
            where: { userId },
            order: { createdAt: 'DESC' },
            take: 20,
        });
    }

    async submitQuiz(userId: string, quizId: string, dto: SubmitQuizDto): Promise<Quiz> {
        const quiz = await this.getQuiz(userId, quizId);

        if (quiz.isCompleted) {
            throw new ForbiddenException('Quiz already completed');
        }

        let correctCount = 0;

        // Process each answer
        for (const answer of dto.answers) {
            const question = quiz.questions.find((q) => q.id === answer.questionId);
            if (question) {
                question.userAnswer = answer.answerIndex;
                question.isCorrect = answer.answerIndex === question.correctOptionIndex;
                if (question.isCorrect) {
                    correctCount++;
                }
                await this.questionRepository.save(question);
            }
        }

        // Update quiz
        quiz.score = correctCount;
        quiz.isCompleted = true;
        quiz.completedAt = new Date();

        return this.quizRepository.save(quiz);
    }

    async deleteQuiz(userId: string, quizId: string): Promise<void> {
        const quiz = await this.getQuiz(userId, quizId);
        await this.quizRepository.remove(quiz);
    }
}
