import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import { StudySessionsService } from './study-sessions.service';
import { CreateStudySessionDto } from './dto/create-study-session.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import { User } from '../users/entities/user.entity';

@Controller('study-sessions')
@UseGuards(JwtAuthGuard)
export class StudySessionsController {
  constructor(private readonly studySessionsService: StudySessionsService) { }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(
    @Body() createStudySessionDto: CreateStudySessionDto,
    @CurrentUser() user: User,
  ) {
    // If recurrenceRule is provided, use createRecurring, otherwise use create
    if (createStudySessionDto.recurrenceRule) {
      return this.studySessionsService.createRecurring(
        user.id,
        createStudySessionDto,
      );
    } else {
      return this.studySessionsService.create(user.id, createStudySessionDto);
    }
  }

  @Patch(':id/status')
  updateStatus(
    @Param('id') id: string,
    @Body('status') status: string,
    @CurrentUser() user: User,
  ) {
    return this.studySessionsService.updateStatus(id, status, user.id);
  }

  @Get('planner')
  getPlanner(
    @CurrentUser() user: User,
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    const start = new Date(startDate);
    const end = new Date(endDate);

    return this.studySessionsService.getPlanner(user.id, start, end);
  }

  @Get('stats/:subjectId')
  getStatsBySubject(@Param('subjectId') subjectId: string) {
    return this.studySessionsService.getStatsBySubject(subjectId);
  }
}

