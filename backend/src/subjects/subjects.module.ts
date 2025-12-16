import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SubjectsService } from './subjects.service';
import { SubjectsController } from './subjects.controller';
import { Subject } from './entities/subject.entity';
import { ClassSchedule } from './entities/class-schedule.entity';
import { StudySessionsModule } from '../study-sessions/study-sessions.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Subject, ClassSchedule]),
    StudySessionsModule,
  ],
  controllers: [SubjectsController],
  providers: [SubjectsService],
  exports: [SubjectsService],
})
export class SubjectsModule {}

