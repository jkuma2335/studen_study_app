import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  Assignment,
  AssignmentPriority,
  AssignmentStatus,
} from './entities/assignment.entity';
import { CreateAssignmentDto } from './dto/create-assignment.dto';
import { UpdateAssignmentDto } from './dto/update-assignment.dto';
import { Subject } from '../subjects/entities/subject.entity';

@Injectable()
export class AssignmentsService {
  constructor(
    @InjectRepository(Assignment)
    private readonly assignmentRepository: Repository<Assignment>,
    @InjectRepository(Subject)
    private readonly subjectRepository: Repository<Subject>,
  ) {}

  async create(createAssignmentDto: CreateAssignmentDto): Promise<Assignment> {
    // Verify subject exists
    const subject = await this.subjectRepository.findOne({
      where: { id: createAssignmentDto.subjectId },
    });

    if (!subject) {
      throw new NotFoundException(
        `Subject with ID ${createAssignmentDto.subjectId} not found`,
      );
    }

    const assignment = this.assignmentRepository.create({
      ...createAssignmentDto,
      dueDate: new Date(createAssignmentDto.dueDate),
      status: createAssignmentDto.status ?? AssignmentStatus.NOT_STARTED,
      priority: createAssignmentDto.priority ?? AssignmentPriority.MEDIUM,
      attachmentUrls: createAssignmentDto.attachmentUrls ?? [],
    });

    return await this.assignmentRepository.save(assignment);
  }

  findAll() {
    return this.assignmentRepository.find({
      relations: ['subject'],
      order: { dueDate: 'ASC' },
    });
  }

  async findOne(id: string): Promise<Assignment> {
    const assignment = await this.assignmentRepository.findOne({
      where: { id },
      relations: ['subject'],
    });

    if (!assignment) {
      throw new NotFoundException(`Assignment with ID ${id} not found`);
    }

    return assignment;
  }

  async findBySubject(subjectId: string): Promise<Assignment[]> {
    // Verify subject exists
    const subject = await this.subjectRepository.findOne({
      where: { id: subjectId },
    });

    if (!subject) {
      throw new NotFoundException(`Subject with ID ${subjectId} not found`);
    }

    return await this.assignmentRepository.find({
      where: { subjectId },
      relations: ['subject'],
      order: { dueDate: 'ASC' },
    });
  }

  async update(
    id: string,
    updateAssignmentDto: UpdateAssignmentDto,
  ): Promise<Assignment> {
    const assignment = await this.findOne(id);

    const updateData: any = { ...updateAssignmentDto };
    if (updateAssignmentDto.dueDate) {
      updateData.dueDate = new Date(updateAssignmentDto.dueDate);
    }

    Object.assign(assignment, updateData);
    return await this.assignmentRepository.save(assignment);
  }

  async remove(id: string): Promise<void> {
    const assignment = await this.findOne(id);
    await this.assignmentRepository.remove(assignment);
  }
}

