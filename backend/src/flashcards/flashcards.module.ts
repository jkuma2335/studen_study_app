import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FlashcardsController } from './flashcards.controller';
import { FlashcardsService } from './flashcards.service';
import { FlashcardDeck } from './entities/flashcard-deck.entity';
import { Flashcard } from './entities/flashcard.entity';

@Module({
    imports: [TypeOrmModule.forFeature([FlashcardDeck, Flashcard])],
    controllers: [FlashcardsController],
    providers: [FlashcardsService],
    exports: [FlashcardsService],
})
export class FlashcardsModule { }
