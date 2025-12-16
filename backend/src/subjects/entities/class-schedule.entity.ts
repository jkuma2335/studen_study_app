import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Subject } from './subject.entity';

@Entity('class_schedules')
export class ClassSchedule {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 10 })
  dayOfWeek: string; // 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'

  @Column({ type: 'varchar', length: 5 })
  startTime: string; // 'HH:mm' format (e.g., '09:00', '14:30')

  @Column({ type: 'varchar', length: 5 })
  endTime: string; // 'HH:mm' format (e.g., '10:30', '16:00')

  @Column({ type: 'varchar', length: 255, nullable: true })
  location: string | null; // e.g., "Room 304", "Building A, Floor 2"

  @Column({ type: 'uuid' })
  subjectId: string;

  @ManyToOne(() => Subject, (subject) => subject.schedules, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'subjectId' })
  subject: Subject;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

