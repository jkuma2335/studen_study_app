import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Assignment } from '../../assignments/entities/assignment.entity';
import { StudySession } from '../../study-sessions/entities/study-session.entity';
import { Note } from '../../notes/entities/note.entity';
import { Document } from '../../documents/entities/document.entity';
import { User } from '../../users/entities/user.entity';
import { ClassSchedule } from './class-schedule.entity';

@Entity('subjects')
export class Subject {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'varchar', length: 7, default: '#3B82F6' })
  color: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  teacherName: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  teacherEmail: string | null;

  @Column({ type: 'varchar', length: 50, nullable: true })
  teacherPhone: string | null;

  @Column({ type: 'float', default: 0 })
  studyGoalHours: number;

  @Column({ type: 'varchar', length: 50, nullable: true })
  category: string | null; // e.g., 'Science', 'Arts', 'Math'

  @Column({ type: 'varchar', length: 10, nullable: true })
  difficulty: string | null; // 'Easy', 'Medium', 'Hard'

  @Column({ type: 'int', default: 0 })
  streak: number; // Cached streak count (can be computed live)

  @Column({ type: 'uuid' })
  userId: string;

  @ManyToOne(() => User, (user) => user.subjects, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'userId' })
  user: User;

  @OneToMany(() => Assignment, (assignment) => assignment.subject)
  assignments: Assignment[];

  @OneToMany(() => StudySession, (studySession) => studySession.subject)
  studySessions: StudySession[];

  @OneToMany(() => Note, (note) => note.subject)
  notes: Note[];

  @OneToMany(() => Document, (document) => document.subject)
  documents: Document[];

  @OneToMany(() => ClassSchedule, (schedule) => schedule.subject, {
    cascade: true,
  })
  schedules: ClassSchedule[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

