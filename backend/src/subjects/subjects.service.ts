import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Subject } from './entities/subject.entity';
import { ClassSchedule } from './entities/class-schedule.entity';
import { CreateSubjectDto } from './dto/create-subject.dto';
import { UpdateSubjectDto } from './dto/update-subject.dto';
import { User } from '../users/entities/user.entity';
import { StudySessionsService } from '../study-sessions/study-sessions.service';

@Injectable()
export class SubjectsService {
  constructor(
    @InjectRepository(Subject)
    private readonly subjectRepository: Repository<Subject>,
    @InjectRepository(ClassSchedule)
    private readonly scheduleRepository: Repository<ClassSchedule>,
    private readonly studySessionsService: StudySessionsService,
  ) {}

  async create(createSubjectDto: CreateSubjectDto, user: User): Promise<Subject> {
    // Create the subject
    const subject = this.subjectRepository.create({
      name: createSubjectDto.name,
      color: createSubjectDto.color || '#3B82F6',
      teacherName: createSubjectDto.teacherName || null,
      teacherEmail: createSubjectDto.teacherEmail || null,
      teacherPhone: createSubjectDto.teacherPhone || null,
      studyGoalHours: createSubjectDto.studyGoalHours || 0,
      category: createSubjectDto.category || null,
      difficulty: createSubjectDto.difficulty || null,
      streak: 0, // Initialize streak to 0
      user: user,
      userId: user.id,
    });

    // Save the subject first (to get the ID)
    const savedSubject = await this.subjectRepository.save(subject);

    // Create and save schedules if provided
    if (createSubjectDto.schedules && createSubjectDto.schedules.length > 0) {
      const schedules = createSubjectDto.schedules.map((scheduleDto) =>
        this.scheduleRepository.create({
          dayOfWeek: this.normalizeDayOfWeek(scheduleDto.dayOfWeek),
          startTime: scheduleDto.startTime,
          endTime: scheduleDto.endTime,
          location: scheduleDto.location || null,
          subject: savedSubject,
          subjectId: savedSubject.id,
        }),
      );
      await this.scheduleRepository.save(schedules);
    }

    // Reload the subject with schedules relation
    return await this.subjectRepository.findOne({
      where: { id: savedSubject.id },
      relations: ['schedules'],
    }) as Subject;
  }

  async findAll(user: User): Promise<Subject[]> {
    const subjects = await this.subjectRepository.find({
      where: { user: { id: user.id } },
      relations: ['schedules'],
      order: { createdAt: 'DESC' },
    });

    // Calculate and update streak for each subject
    for (const subject of subjects) {
      try {
        const streak = await this.studySessionsService.calculateSubjectStreak(subject.id);
        // Update the cached streak value
        subject.streak = streak;
        // Optionally save to database (or compute live)
        await this.subjectRepository.update(subject.id, { streak });
      } catch (error) {
        // If streak calculation fails, keep existing streak value
        console.error(`Failed to calculate streak for subject ${subject.id}:`, error);
      }
    }

    return subjects;
  }

  async findOne(id: string, user: User): Promise<Subject> {
    const subject = await this.subjectRepository.findOne({
      where: { id, user: { id: user.id } },
      relations: ['schedules'],
    });
    if (!subject) {
      throw new NotFoundException(`Subject with ID ${id} not found`);
    }

    // Calculate and update streak
    try {
      const streak = await this.studySessionsService.calculateSubjectStreak(subject.id);
      subject.streak = streak;
      // Optionally save to database (or compute live)
      await this.subjectRepository.update(subject.id, { streak });
    } catch (error) {
      // If streak calculation fails, keep existing streak value
      console.error(`Failed to calculate streak for subject ${subject.id}:`, error);
    }

    return subject;
  }

  async update(id: string, updateSubjectDto: UpdateSubjectDto, user: User): Promise<Subject> {
    const subject = await this.findOne(id, user);
    
    // Update basic subject fields (excluding schedules)
    const { schedules, ...subjectFields } = updateSubjectDto;
    Object.assign(subject, subjectFields);
    
    // Save the subject first
    const savedSubject = await this.subjectRepository.save(subject);
    
    // Handle schedules update if provided
    if (schedules !== undefined) {
      // Delete existing schedules
      await this.scheduleRepository.delete({ subjectId: savedSubject.id });
      
      // Create new schedules if provided
      if (schedules.length > 0) {
        const newSchedules = schedules.map((scheduleDto) =>
          this.scheduleRepository.create({
            dayOfWeek: this.normalizeDayOfWeek(scheduleDto.dayOfWeek),
            startTime: scheduleDto.startTime,
            endTime: scheduleDto.endTime,
            location: scheduleDto.location || null,
            subject: savedSubject,
            subjectId: savedSubject.id,
          }),
        );
        await this.scheduleRepository.save(newSchedules);
      }
    }
    
    // Reload the subject with schedules relation
    return await this.subjectRepository.findOne({
      where: { id: savedSubject.id },
      relations: ['schedules'],
    }) as Subject;
  }

  async remove(id: string, user: User): Promise<void> {
    const subject = await this.findOne(id, user);
    await this.subjectRepository.remove(subject);
  }

  /**
   * Normalize day of week to proper format (capitalize first letter, lowercase rest)
   * e.g., "mon" -> "Mon", "MONDAY" -> "Mon"
   */
  private normalizeDayOfWeek(day: string): string {
    const normalized = day.toLowerCase();
    const dayMap: { [key: string]: string } = {
      monday: 'Mon',
      tuesday: 'Tue',
      wednesday: 'Wed',
      thursday: 'Thu',
      friday: 'Fri',
      saturday: 'Sat',
      sunday: 'Sun',
      mon: 'Mon',
      tue: 'Tue',
      wed: 'Wed',
      thu: 'Thu',
      fri: 'Fri',
      sat: 'Sat',
      sun: 'Sun',
    };
    return dayMap[normalized] || day.charAt(0).toUpperCase() + day.slice(1).toLowerCase();
  }
}

