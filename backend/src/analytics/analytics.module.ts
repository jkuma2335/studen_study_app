import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AnalyticsController } from './analytics.controller';
import { AnalyticsService } from './analytics.service';
import { StudySession } from '../study-sessions/entities/study-session.entity';
import { Subject } from '../subjects/entities/subject.entity';

@Module({
    imports: [TypeOrmModule.forFeature([StudySession, Subject])],
    controllers: [AnalyticsController],
    providers: [AnalyticsService],
    exports: [AnalyticsService],
})
export class AnalyticsModule { }
