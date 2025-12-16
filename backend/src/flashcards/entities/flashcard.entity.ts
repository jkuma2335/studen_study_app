import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
    ManyToOne,
    JoinColumn,
} from 'typeorm';
import { FlashcardDeck } from './flashcard-deck.entity';

export enum CardDifficulty {
    EASY = 'easy',
    MEDIUM = 'medium',
    HARD = 'hard',
}

@Entity('flashcards')
export class Flashcard {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ type: 'text' })
    front: string;

    @Column({ type: 'text' })
    back: string;

    @Column({ type: 'uuid' })
    deckId: string;

    @ManyToOne('FlashcardDeck', 'cards', { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'deckId' })
    deck: FlashcardDeck;

    @Column({
        type: 'enum',
        enum: CardDifficulty,
        default: CardDifficulty.MEDIUM,
    })
    difficulty: CardDifficulty;

    @Column({ type: 'int', default: 0 })
    timesReviewed: number;

    @Column({ type: 'int', default: 0 })
    timesCorrect: number;

    @Column({ type: 'timestamp', nullable: true })
    lastReviewedAt: Date | null;

    @Column({ type: 'timestamp', nullable: true })
    nextReviewAt: Date | null;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
