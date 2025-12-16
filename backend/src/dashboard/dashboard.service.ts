import { Injectable } from '@nestjs/common';
import { AssignmentsService } from '../assignments/assignments.service';
import { StudySessionsService } from '../study-sessions/study-sessions.service';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  Assignment,
  AssignmentStatus,
} from '../assignments/entities/assignment.entity';
import { StudySession } from '../study-sessions/entities/study-session.entity';

export interface DashboardStats {
  assignmentsPending: number;
  assignmentsDueSoon: Assignment[];
  studyMinutesToday: number;
}

@Injectable()
export class DashboardService {
  constructor(
    private readonly assignmentsService: AssignmentsService,
    private readonly studySessionsService: StudySessionsService,
    @InjectRepository(Assignment)
    private readonly assignmentRepository: Repository<Assignment>,
    @InjectRepository(StudySession)
    private readonly studySessionRepository: Repository<StudySession>,
  ) {}

  async getStats(): Promise<DashboardStats> {
    // Get all assignments
    const allAssignments = await this.assignmentsService.findAll();

    // Count incomplete assignments (NOT_STARTED or IN_PROGRESS)
    const assignmentsPending = allAssignments.filter(
      (assignment) =>
        assignment.status !== AssignmentStatus.COMPLETED,
    ).length;

    // Get next 3 incomplete assignments sorted by due date
    const assignmentsDueSoon = allAssignments
      .filter(
        (assignment) =>
          assignment.status !== AssignmentStatus.COMPLETED,
      )
      .sort((a, b) => a.dueDate.getTime() - b.dueDate.getTime())
      .slice(0, 3);

    // Calculate study minutes for today
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const todaySessions = await this.studySessionRepository
      .createQueryBuilder('session')
      .where('session.startTime >= :today', { today })
      .andWhere('session.startTime < :tomorrow', { tomorrow })
      .getMany();

    const studyMinutesToday = todaySessions.reduce(
      (sum, session) => sum + session.durationMinutes,
      0,
    );

    return {
      assignmentsPending,
      assignmentsDueSoon,
      studyMinutesToday,
    };
  }
}
