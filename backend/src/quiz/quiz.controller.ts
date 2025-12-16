import {
    Controller,
    Get,
    Post,
    Delete,
    Body,
    Param,
    UseGuards,
    Request,
} from '@nestjs/common';
import { QuizService } from './quiz.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GenerateQuizDto, SubmitQuizDto } from './dto/quiz.dto';

@Controller('quiz')
@UseGuards(JwtAuthGuard)
export class QuizController {
    constructor(private readonly quizService: QuizService) { }

    @Post('generate')
    async generateQuiz(@Request() req, @Body() dto: GenerateQuizDto) {
        return this.quizService.generateQuiz(req.user.id, dto);
    }

    @Get('history')
    async getHistory(@Request() req) {
        return this.quizService.getQuizHistory(req.user.id);
    }

    @Get(':id')
    async getQuiz(@Request() req, @Param('id') id: string) {
        return this.quizService.getQuiz(req.user.id, id);
    }

    @Post(':id/submit')
    async submitQuiz(
        @Request() req,
        @Param('id') id: string,
        @Body() dto: SubmitQuizDto,
    ) {
        return this.quizService.submitQuiz(req.user.id, id, dto);
    }

    @Delete(':id')
    async deleteQuiz(@Request() req, @Param('id') id: string) {
        await this.quizService.deleteQuiz(req.user.id, id);
        return { message: 'Quiz deleted successfully' };
    }
}
