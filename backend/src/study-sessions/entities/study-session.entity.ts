import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  JoinColumn,
} from 'typeorm';
import { Subject } from '../../subjects/entities/subject.entity';
import { FocusType } from '../enums/focus-type.enum';
import { SessionStatus } from '../enums/session-status.enum';

@Entity('study_sessions')
export class StudySession {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'int' })
  durationMinutes: number;

  @Column({ type: 'timestamp', nullable: true })
  startTime: Date | null;

  @Column({ type: 'timestamp', nullable: true })
  endTime: Date | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  title: string | null;

  @Column({
    type: 'enum',
    enum: FocusType,
    default: FocusType.DEEP_FOCUS,
  })
  focusType: FocusType;

  @Column({
    type: 'enum',
    enum: SessionStatus,
    default: SessionStatus.COMPLETED,
  })
  status: SessionStatus;

  @Column({ type: 'uuid', nullable: true })
  recurrenceGroupId: string | null;

  @Column({ type: 'uuid' })
  subjectId: string;

  @ManyToOne(() => Subject, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'subjectId' })
  subject: Subject;

  @CreateDateColumn()
  createdAt: Date;
}

