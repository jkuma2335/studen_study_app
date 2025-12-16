import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
  JoinColumn,
} from 'typeorm';
import { Subject } from '../../subjects/entities/subject.entity';

export enum AssignmentPriority {
  HIGH = 'High',
  MEDIUM = 'Medium',
  LOW = 'Low',
}

export enum AssignmentStatus {
  NOT_STARTED = 'NOT_STARTED',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
}

@Entity('assignments')
export class Assignment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({ type: 'timestamp' })
  dueDate: Date;

  @Column({
    type: 'enum',
    enum: AssignmentStatus,
    default: AssignmentStatus.NOT_STARTED,
  })
  status: AssignmentStatus;

  @Column({
    type: 'enum',
    enum: AssignmentPriority,
    default: AssignmentPriority.MEDIUM,
  })
  priority: AssignmentPriority;

  @Column({ type: 'text', array: true, default: [] })
  attachmentUrls: string[];

  @Column({ type: 'uuid' })
  subjectId: string;

  @ManyToOne(() => Subject, (subject) => subject.assignments, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'subjectId' })
  subject: Subject;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

