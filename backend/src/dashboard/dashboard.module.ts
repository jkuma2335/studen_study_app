import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DashboardService } from './dashboard.service';
import { DashboardController } from './dashboard.controller';
import { AssignmentsModule } from '../assignments/assignments.module';
import { StudySessionsModule } from '../study-sessions/study-sessions.module';
import { Assignment } from '../assignments/entities/assignment.entity';
import { StudySession } from '../study-sessions/entities/study-session.entity';

@Module({
  imports: [
    AssignmentsModule,
    StudySessionsModule,
    TypeOrmModule.forFeature([Assignment, StudySession]),
  ],
  controllers: [DashboardController],
  providers: [DashboardService],
})
export class DashboardModule {}
