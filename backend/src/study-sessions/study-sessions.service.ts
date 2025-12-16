import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { randomUUID } from 'crypto';
import { StudySession } from './entities/study-session.entity';
import { CreateStudySessionDto } from './dto/create-study-session.dto';
import { Subject } from '../subjects/entities/subject.entity';
import { FocusType } from './enums/focus-type.enum';
import { SessionStatus } from './enums/session-status.enum';

@Injectable()
export class StudySessionsService {
  constructor(
    @InjectRepository(StudySession)
    private readonly studySessionRepository: Repository<StudySession>,
    @InjectRepository(Subject)
    private readonly subjectRepository: Repository<Subject>,
  ) { }

  async logSession(
    subjectId: string,
    durationMinutes: number,
    startTime?: Date,
  ): Promise<StudySession> {
    // Verify subject exists
    const subject = await this.subjectRepository.findOne({
      where: { id: subjectId },
    });

    if (!subject) {
      throw new NotFoundException(
        `Subject with ID ${subjectId} not found`,
      );
    }

    const start = startTime || new Date();
    const end = new Date(start.getTime() + durationMinutes * 60 * 1000);

    const studySession = this.studySessionRepository.create({
      subjectId,
      durationMinutes,
      startTime: start,
      endTime: end,
      status: SessionStatus.COMPLETED,
      focusType: FocusType.DEEP_FOCUS,
    });

    return await this.studySessionRepository.save(studySession);
  }

  /**
   * Get planner sessions for a user within a date range.
   * Fetches sessions where startTime is between start and end dates.
   */
  async getPlanner(
    userId: string,
    start: Date,
    end: Date,
  ): Promise<StudySession[]> {
    return await this.studySessionRepository
      .createQueryBuilder('session')
      .leftJoinAndSelect('session.subject', 'subject')
      .where('subject.userId = :userId', { userId })
      .andWhere('session.startTime IS NOT NULL')
      .andWhere('session.startTime >= :start', { start })
      .andWhere('session.startTime <= :end', { end })
      .orderBy('session.startTime', 'ASC')
      .getMany();
  }

  /**
   * Update the status of a study session.
   */
  async updateStatus(
    id: string,
    status: string,
    userId: string,
  ): Promise<StudySession> {
    // Find the session with its subject to verify ownership
    const session = await this.studySessionRepository.findOne({
      where: { id },
      relations: ['subject'],
    });

    if (!session) {
      throw new NotFoundException(`Study session with ID ${id} not found`);
    }

    // Verify the session belongs to the user
    if (session.subject?.userId !== userId) {
      throw new NotFoundException(`Study session with ID ${id} not found`);
    }

    // Update the status
    session.status = status as SessionStatus;
    return await this.studySessionRepository.save(session);
  }


  /**
   * Create a single study session from DTO.
   */
  async create(
    userId: string,
    data: CreateStudySessionDto,
  ): Promise<StudySession> {
    // Verify subject exists and belongs to user
    const subject = await this.subjectRepository.findOne({
      where: { id: data.subjectId, userId },
    });

    if (!subject) {
      throw new NotFoundException(
        `Subject with ID ${data.subjectId} not found`,
      );
    }

    const startTime = data.startTime ? new Date(data.startTime) : null;
    const endTime = data.endTime ? new Date(data.endTime) : null;

    // Calculate duration if not provided or if we have start/end times
    let durationMinutes = data.durationMinutes;
    if (startTime && endTime && !durationMinutes) {
      durationMinutes = Math.round(
        (endTime.getTime() - startTime.getTime()) / (1000 * 60),
      );
    }

    const studySession = this.studySessionRepository.create({
      subjectId: data.subjectId,
      durationMinutes: durationMinutes || 25, // Default 25 minutes
      startTime,
      endTime,
      title: data.title || null,
      focusType: data.focusType || FocusType.DEEP_FOCUS,
      status: data.status || SessionStatus.PLANNED,
    });

    return await this.studySessionRepository.save(studySession);
  }

  /**
   * Create recurring study sessions based on recurrence rule.
   * Generates individual Session records for specified dates and links them with recurrenceGroupId.
   */
  async createRecurring(
    userId: string,
    data: CreateStudySessionDto,
  ): Promise<StudySession[]> {
    if (!data.recurrenceRule) {
      // If no recurrence rule, just create a single session
      return [await this.create(userId, data)];
    }

    const recurrenceGroupId = randomUUID();
    const sessions: StudySession[] = [];

    // Verify subject exists and belongs to user
    const subject = await this.subjectRepository.findOne({
      where: { id: data.subjectId, userId },
    });

    if (!subject) {
      throw new NotFoundException(
        `Subject with ID ${data.subjectId} not found`,
      );
    }

    const baseStartTime = data.startTime ? new Date(data.startTime) : new Date();
    const untilDate = new Date(data.recurrenceRule.until);
    const durationMinutes = data.durationMinutes || 25;

    // Preserve the time components (hours, minutes, seconds) from baseStartTime
    const baseHour = baseStartTime.getHours();
    const baseMinute = baseStartTime.getMinutes();
    const baseSecond = baseStartTime.getSeconds();

    // Start from the date of baseStartTime (normalized to start of day)
    let currentDate = new Date(baseStartTime);
    currentDate.setHours(0, 0, 0, 0);

    if (data.recurrenceRule.frequency === 'DAILY') {
      // Create sessions for every day until the 'until' date
      while (currentDate <= untilDate) {
        const sessionStart = new Date(currentDate);
        sessionStart.setHours(baseHour, baseMinute, baseSecond, 0);
        const sessionEnd = new Date(
          sessionStart.getTime() + durationMinutes * 60 * 1000,
        );

        const session = this.studySessionRepository.create({
          subjectId: data.subjectId,
          durationMinutes,
          startTime: sessionStart,
          endTime: sessionEnd,
          title: data.title || null,
          focusType: data.focusType || FocusType.DEEP_FOCUS,
          status: data.status || SessionStatus.PLANNED,
          recurrenceGroupId,
        });

        sessions.push(session);

        // Move to next day
        currentDate.setDate(currentDate.getDate() + 1);
      }
    } else if (data.recurrenceRule.frequency === 'WEEKLY') {
      // Create sessions for specified days of the week until the 'until' date
      const daysOfWeek = data.recurrenceRule.days || []; // [1,3,5] = Mon, Wed, Fri

      while (currentDate <= untilDate) {
        const dayOfWeek = currentDate.getDay(); // 0 = Sunday, 1 = Monday, etc.

        if (daysOfWeek.includes(dayOfWeek)) {
          const sessionStart = new Date(currentDate);
          sessionStart.setHours(baseHour, baseMinute, baseSecond, 0);
          const sessionEnd = new Date(
            sessionStart.getTime() + durationMinutes * 60 * 1000,
          );

          const session = this.studySessionRepository.create({
            subjectId: data.subjectId,
            durationMinutes,
            startTime: sessionStart,
            endTime: sessionEnd,
            title: data.title || null,
            focusType: data.focusType || FocusType.DEEP_FOCUS,
            status: data.status || SessionStatus.PLANNED,
            recurrenceGroupId,
          });

          sessions.push(session);
        }

        // Move to next day
        currentDate.setDate(currentDate.getDate() + 1);
      }
    }

    // Save all sessions in a transaction
    return await this.studySessionRepository.save(sessions);
  }

  async getStatsBySubject(subjectId: string): Promise<{ totalMinutes: number }> {
    // Verify subject exists
    const subject = await this.subjectRepository.findOne({
      where: { id: subjectId },
    });

    if (!subject) {
      throw new NotFoundException(
        `Subject with ID ${subjectId} not found`,
      );
    }

    const result = await this.studySessionRepository
      .createQueryBuilder('session')
      .select('SUM(session.durationMinutes)', 'totalMinutes')
      .where('session.subjectId = :subjectId', { subjectId })
      .getRawOne();

    return {
      totalMinutes: parseInt(result?.totalMinutes || '0', 10),
    };
  }

  /**
   * Calculate the current streak for a subject based on study sessions.
   * A streak is the number of consecutive days (including today) that the subject was studied.
   * 
   * Logic:
   * - Fetch all study sessions for this subject, ordered by startTime DESC
   * - Get unique study dates (normalize to start of day)
   * - Check if today or yesterday was studied, if not, streak is 0
   * - Count backwards consecutive days until a gap is found
   * - Return the integer count
   */
  async calculateSubjectStreak(subjectId: string): Promise<number> {
    // Verify subject exists
    const subject = await this.subjectRepository.findOne({
      where: { id: subjectId },
    });

    if (!subject) {
      throw new NotFoundException(
        `Subject with ID ${subjectId} not found`,
      );
    }

    // Fetch all study sessions for this subject, ordered by startTime DESC
    const sessions = await this.studySessionRepository.find({
      where: { subjectId },
      order: { startTime: 'DESC' },
    });

    if (sessions.length === 0) {
      return 0;
    }

    // Get unique study dates (normalize to start of day)
    const studyDatesSet = new Set<string>();
    sessions.forEach((session) => {
      if (session.startTime) {
        const date = new Date(session.startTime);
        date.setHours(0, 0, 0, 0);
        studyDatesSet.add(date.toISOString().split('T')[0]); // Format: YYYY-MM-DD
      }
    });

    // Calculate streak
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayStr = today.toISOString().split('T')[0];

    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().split('T')[0];

    // Check if today or yesterday was studied
    const mostRecentStudyDate = Array.from(studyDatesSet)
      .sort()
      .reverse()[0]; // Get most recent date

    // If the most recent study was not today or yesterday, streak is 0
    if (mostRecentStudyDate !== todayStr && mostRecentStudyDate !== yesterdayStr) {
      return 0;
    }

    // Start counting from today or yesterday (whichever was studied most recently)
    let checkDate = new Date(mostRecentStudyDate === todayStr ? today : yesterday);
    let streak = 0;

    // Count consecutive days backwards
    while (true) {
      const checkDateStr = checkDate.toISOString().split('T')[0];

      if (studyDatesSet.has(checkDateStr)) {
        streak++;
        // Move to previous day
        checkDate.setDate(checkDate.getDate() - 1);
      } else {
        // Gap found, stop counting
        break;
      }
    }

    return streak;
  }
}

