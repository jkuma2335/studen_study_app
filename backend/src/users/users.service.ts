import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { User } from './entities/user.entity';
import { Subject } from '../subjects/entities/subject.entity';
import {
  Assignment,
  AssignmentStatus,
} from '../assignments/entities/assignment.entity';
import { StudySession } from '../study-sessions/entities/study-session.entity';

export interface ProfileStats {
  totalStudyHours: number;
  tasksCompleted: number;
  streakDays: number;
}

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Subject)
    private readonly subjectRepository: Repository<Subject>,
    @InjectRepository(Assignment)
    private readonly assignmentRepository: Repository<Assignment>,
    @InjectRepository(StudySession)
    private readonly studySessionRepository: Repository<StudySession>,
  ) {}

  async create(createUserDto: CreateUserDto): Promise<User> {
    const user = this.userRepository.create(createUserDto);
    return await this.userRepository.save(user);
  }

  async findAll(): Promise<User[]> {
    return await this.userRepository.find();
  }

  async findOne(id: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    return user;
  }

  async findByEmail(email: string): Promise<User | null> {
    return await this.userRepository.findOne({ where: { email } });
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const user = await this.findOne(id);
    Object.assign(user, updateUserDto);
    return await this.userRepository.save(user);
  }

  async remove(id: string): Promise<void> {
    const user = await this.findOne(id);
    await this.userRepository.remove(user);
  }

  // Get user profile without password
  async getProfile(userId: string): Promise<Omit<User, 'password'>> {
    const user = await this.findOne(userId);
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password, ...profile } = user;
    return profile;
  }

  // Get profile stats (total hours, completed tasks, streak)
  async getProfileStats(userId: string): Promise<ProfileStats> {
    // Get all subjects for this user
    const subjects = await this.subjectRepository.find({
      where: { userId },
      select: ['id'],
    });
    const subjectIds = subjects.map((s) => s.id);

    if (subjectIds.length === 0) {
      return {
        totalStudyHours: 0,
        tasksCompleted: 0,
        streakDays: 0,
      };
    }

    // Calculate total study hours (in minutes, convert to hours)
    const studySessions = await this.studySessionRepository
      .createQueryBuilder('session')
      .where('session.subjectId IN (:...subjectIds)', { subjectIds })
      .getMany();

    const totalMinutes = studySessions.reduce(
      (sum, session) => sum + session.durationMinutes,
      0,
    );
    const totalStudyHours = totalMinutes / 60;

    // Count completed tasks
    const completedTasks = await this.assignmentRepository.count({
      where: {
        subjectId: In(subjectIds),
        status: AssignmentStatus.COMPLETED,
      },
    });

    // Calculate streak (consecutive days with at least one study session)
    const streakDays = this.calculateStreak(studySessions);

    return {
      totalStudyHours: Math.round(totalStudyHours * 10) / 10, // Round to 1 decimal
      tasksCompleted: completedTasks,
      streakDays,
    };
  }

  private calculateStreak(sessions: StudySession[]): number {
    if (sessions.length === 0) return 0;

    // Group sessions by date (YYYY-MM-DD)
    const sessionsByDate = new Map<string, StudySession[]>();
    sessions.forEach((session) => {
      if (session.startTime) {
        const dateKey = session.startTime.toISOString().split('T')[0];
        if (!sessionsByDate.has(dateKey)) {
          sessionsByDate.set(dateKey, []);
        }
        sessionsByDate.get(dateKey)!.push(session);
      }
    });

    // Sort dates descending
    const sortedDates = Array.from(sessionsByDate.keys()).sort().reverse();

    // Calculate streak from today backwards
    let streak = 0;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    for (let i = 0; i < sortedDates.length; i++) {
      const dateStr = sortedDates[i];
      const date = new Date(dateStr);
      date.setHours(0, 0, 0, 0);

      const expectedDate = new Date(today);
      expectedDate.setDate(expectedDate.getDate() - i);

      // Check if this date matches the expected date in the streak
      if (
        date.getTime() === expectedDate.getTime() ||
        (i === 0 && date.getTime() <= today.getTime())
      ) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
