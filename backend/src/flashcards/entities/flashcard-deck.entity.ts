import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
    OneToMany,
    ManyToOne,
    JoinColumn,
} from 'typeorm';
import { Subject } from '../../subjects/entities/subject.entity';
import type { Flashcard } from './flashcard.entity';

@Entity('flashcard_decks')
export class FlashcardDeck {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ type: 'varchar', length: 255 })
    name: string;

    @Column({ type: 'text', nullable: true })
    description: string | null;

    @Column({ type: 'uuid' })
    userId: string;

    @Column({ type: 'uuid', nullable: true })
    subjectId: string | null;

    @ManyToOne(() => Subject, { onDelete: 'SET NULL', nullable: true })
    @JoinColumn({ name: 'subjectId' })
    subject: Subject | null;

    @OneToMany('Flashcard', 'deck', { cascade: true })
    cards: Flashcard[];

    @Column({ type: 'varchar', length: 7, default: '#6366F1' })
    color: string;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;

    @Column({ type: 'timestamp', nullable: true })
    lastStudiedAt: Date | null;
}
