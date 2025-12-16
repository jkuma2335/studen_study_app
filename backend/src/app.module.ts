import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { SubjectsModule } from './subjects/subjects.module';
import { AssignmentsModule } from './assignments/assignments.module';
import { StudySessionsModule } from './study-sessions/study-sessions.module';
import { NotesModule } from './notes/notes.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { DocumentsModule } from './documents/documents.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { FlashcardsModule } from './flashcards/flashcards.module';
import { QuizModule } from './quiz/quiz.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: 'localhost',
      port: 5435,
      username: 'student_study_user',
      password: 'student_study_password',
      database: 'student_study_db',
      autoLoadEntities: true,
      synchronize: true, // Set to false in production
      logging: true,
    }),
    SubjectsModule,
    AssignmentsModule,
    StudySessionsModule,
    NotesModule,
    DashboardModule,
    DocumentsModule,
    UsersModule,
    AuthModule,
    AnalyticsModule,
    FlashcardsModule,
    QuizModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
