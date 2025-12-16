import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { QuizController } from './quiz.controller';
import { QuizService } from './quiz.service';
import { AiService } from './ai.service';
import { Quiz } from './entities/quiz.entity';
import { QuizQuestion } from './entities/quiz-question.entity';

@Module({
    imports: [TypeOrmModule.forFeature([Quiz, QuizQuestion])],
    controllers: [QuizController],
    providers: [QuizService, AiService],
    exports: [QuizService],
})
export class QuizModule { }
