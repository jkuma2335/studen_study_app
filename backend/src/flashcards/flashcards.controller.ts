import {
    Controller,
    Get,
    Post,
    Put,
    Delete,
    Body,
    Param,
    UseGuards,
    Request,
} from '@nestjs/common';
import { FlashcardsService } from './flashcards.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import {
    CreateDeckDto,
    UpdateDeckDto,
    CreateCardDto,
    UpdateCardDto,
    ReviewCardDto,
} from './dto/flashcard.dto';

@Controller('flashcards')
@UseGuards(JwtAuthGuard)
export class FlashcardsController {
    constructor(private readonly flashcardsService: FlashcardsService) { }

    // ============= DECK ENDPOINTS =============

    @Post('decks')
    async createDeck(@Request() req, @Body() dto: CreateDeckDto) {
        return this.flashcardsService.createDeck(req.user.id, dto);
    }

    @Get('decks')
    async getDecks(@Request() req) {
        return this.flashcardsService.getDecks(req.user.id);
    }

    @Get('decks/:id')
    async getDeck(@Request() req, @Param('id') id: string) {
        return this.flashcardsService.getDeck(req.user.id, id);
    }

    @Put('decks/:id')
    async updateDeck(
        @Request() req,
        @Param('id') id: string,
        @Body() dto: UpdateDeckDto,
    ) {
        return this.flashcardsService.updateDeck(req.user.id, id, dto);
    }

    @Delete('decks/:id')
    async deleteDeck(@Request() req, @Param('id') id: string) {
        await this.flashcardsService.deleteDeck(req.user.id, id);
        return { message: 'Deck deleted successfully' };
    }

    // ============= CARD ENDPOINTS =============

    @Post('decks/:deckId/cards')
    async addCard(
        @Request() req,
        @Param('deckId') deckId: string,
        @Body() dto: CreateCardDto,
    ) {
        return this.flashcardsService.addCard(req.user.id, deckId, dto);
    }

    @Get('decks/:deckId/due')
    async getDueCards(@Request() req, @Param('deckId') deckId: string) {
        return this.flashcardsService.getDueCards(req.user.id, deckId);
    }

    @Put('cards/:id')
    async updateCard(
        @Request() req,
        @Param('id') id: string,
        @Body() dto: UpdateCardDto,
    ) {
        return this.flashcardsService.updateCard(req.user.id, id, dto);
    }

    @Delete('cards/:id')
    async deleteCard(@Request() req, @Param('id') id: string) {
        await this.flashcardsService.deleteCard(req.user.id, id);
        return { message: 'Card deleted successfully' };
    }

    @Post('cards/:id/review')
    async reviewCard(
        @Request() req,
        @Param('id') id: string,
        @Body() dto: ReviewCardDto,
    ) {
        return this.flashcardsService.reviewCard(req.user.id, id, dto);
    }
}
