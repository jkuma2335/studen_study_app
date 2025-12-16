import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    OneToMany,
} from 'typeorm';
import type { QuizQuestion } from './quiz-question.entity';

@Entity('quizzes')
export class Quiz {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ type: 'varchar', length: 255 })
    title: string;

    @Column({ type: 'uuid' })
    userId: string;

    @Column({ type: 'uuid', nullable: true })
    noteId: string | null;

    @Column({ type: 'uuid', nullable: true })
    subjectId: string | null;

    @Column({ type: 'int', default: 0 })
    totalQuestions: number;

    @Column({ type: 'int', nullable: true })
    score: number | null;

    @Column({ type: 'boolean', default: false })
    isCompleted: boolean;

    @OneToMany('QuizQuestion', 'quiz', { cascade: true })
    questions: QuizQuestion[];

    @CreateDateColumn()
    createdAt: Date;

    @Column({ type: 'timestamp', nullable: true })
    completedAt: Date | null;
}
