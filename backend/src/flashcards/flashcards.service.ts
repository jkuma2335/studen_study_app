import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FlashcardDeck } from './entities/flashcard-deck.entity';
import { Flashcard, CardDifficulty } from './entities/flashcard.entity';
import {
    CreateDeckDto,
    UpdateDeckDto,
    CreateCardDto,
    UpdateCardDto,
    ReviewCardDto,
} from './dto/flashcard.dto';

@Injectable()
export class FlashcardsService {
    constructor(
        @InjectRepository(FlashcardDeck)
        private deckRepository: Repository<FlashcardDeck>,
        @InjectRepository(Flashcard)
        private cardRepository: Repository<Flashcard>,
    ) { }

    // ============= DECK OPERATIONS =============

    async createDeck(userId: string, dto: CreateDeckDto): Promise<FlashcardDeck> {
        const deck = this.deckRepository.create({
            ...dto,
            userId,
            color: dto.color || '#6366F1',
        });
        return this.deckRepository.save(deck);
    }

    async getDecks(userId: string): Promise<FlashcardDeck[]> {
        return this.deckRepository.find({
            where: { userId },
            relations: ['cards', 'subject'],
            order: { updatedAt: 'DESC' },
        });
    }

    async getDeck(userId: string, deckId: string): Promise<FlashcardDeck> {
        const deck = await this.deckRepository.findOne({
            where: { id: deckId },
            relations: ['cards', 'subject'],
        });

        if (!deck) {
            throw new NotFoundException('Deck not found');
        }

        if (deck.userId !== userId) {
            throw new ForbiddenException('Access denied');
        }

        return deck;
    }

    async updateDeck(userId: string, deckId: string, dto: UpdateDeckDto): Promise<FlashcardDeck> {
        const deck = await this.getDeck(userId, deckId);
        Object.assign(deck, dto);
        return this.deckRepository.save(deck);
    }

    async deleteDeck(userId: string, deckId: string): Promise<void> {
        const deck = await this.getDeck(userId, deckId);
        await this.deckRepository.remove(deck);
    }

    // ============= CARD OPERATIONS =============

    async addCard(userId: string, deckId: string, dto: CreateCardDto): Promise<Flashcard> {
        const deck = await this.getDeck(userId, deckId);

        const card = this.cardRepository.create({
            ...dto,
            deckId: deck.id,
        });

        return this.cardRepository.save(card);
    }

    async updateCard(userId: string, cardId: string, dto: UpdateCardDto): Promise<Flashcard> {
        const card = await this.cardRepository.findOne({
            where: { id: cardId },
            relations: ['deck'],
        });

        if (!card) {
            throw new NotFoundException('Card not found');
        }

        if (card.deck.userId !== userId) {
            throw new ForbiddenException('Access denied');
        }

        Object.assign(card, dto);
        return this.cardRepository.save(card);
    }

    async deleteCard(userId: string, cardId: string): Promise<void> {
        const card = await this.cardRepository.findOne({
            where: { id: cardId },
            relations: ['deck'],
        });

        if (!card) {
            throw new NotFoundException('Card not found');
        }

        if (card.deck.userId !== userId) {
            throw new ForbiddenException('Access denied');
        }

        await this.cardRepository.remove(card);
    }

    async reviewCard(userId: string, cardId: string, dto: ReviewCardDto): Promise<Flashcard> {
        const card = await this.cardRepository.findOne({
            where: { id: cardId },
            relations: ['deck'],
        });

        if (!card) {
            throw new NotFoundException('Card not found');
        }

        if (card.deck.userId !== userId) {
            throw new ForbiddenException('Access denied');
        }

        // Update review stats
        card.timesReviewed += 1;
        if (dto.correct !== false) {
            card.timesCorrect += 1;
        }
        card.lastReviewedAt = new Date();
        card.difficulty = dto.difficulty as CardDifficulty;

        // Simple spaced repetition: schedule next review based on difficulty
        const now = new Date();
        switch (dto.difficulty) {
            case 'easy':
                card.nextReviewAt = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000); // 7 days
                break;
            case 'medium':
                card.nextReviewAt = new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000); // 3 days
                break;
            case 'hard':
                card.nextReviewAt = new Date(now.getTime() + 1 * 24 * 60 * 60 * 1000); // 1 day
                break;
        }

        // Update deck lastStudiedAt
        await this.deckRepository.update(card.deckId, { lastStudiedAt: new Date() });

        return this.cardRepository.save(card);
    }

    // Get cards due for review
    async getDueCards(userId: string, deckId: string): Promise<Flashcard[]> {
        const deck = await this.getDeck(userId, deckId);
        const now = new Date();

        return this.cardRepository
            .createQueryBuilder('card')
            .where('card.deckId = :deckId', { deckId: deck.id })
            .andWhere('(card.nextReviewAt IS NULL OR card.nextReviewAt <= :now)', { now })
            .orderBy('card.nextReviewAt', 'ASC', 'NULLS FIRST')
            .getMany();
    }
}
