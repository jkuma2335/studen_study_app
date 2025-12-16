import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    ManyToOne,
    JoinColumn,
} from 'typeorm';
import { Quiz } from './quiz.entity';

@Entity('quiz_questions')
export class QuizQuestion {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ type: 'text' })
    question: string;

    @Column({ type: 'simple-array' })
    options: string[];

    @Column({ type: 'int' })
    correctOptionIndex: number;

    @Column({ type: 'text', nullable: true })
    explanation: string | null;

    @Column({ type: 'uuid' })
    quizId: string;

    @ManyToOne('Quiz', 'questions', { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'quizId' })
    quiz: Quiz;

    @Column({ type: 'int', nullable: true })
    userAnswer: number | null;

    @Column({ type: 'boolean', nullable: true })
    isCorrect: boolean | null;
}
