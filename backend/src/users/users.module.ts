import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { User } from './entities/user.entity';
import { Subject } from '../subjects/entities/subject.entity';
import { Assignment } from '../assignments/entities/assignment.entity';
import { StudySession } from '../study-sessions/entities/study-session.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([User, Subject, Assignment, StudySession]),
  ],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService, TypeOrmModule], // Export UsersService and TypeOrmModule for use in AuthModule
})
export class UsersModule {}
