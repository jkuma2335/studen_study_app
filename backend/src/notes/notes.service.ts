import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Note } from './entities/note.entity';
import { CreateNoteDto } from './dto/create-note.dto';
import { UpdateNoteDto } from './dto/update-note.dto';
import { Subject } from '../subjects/entities/subject.entity';

@Injectable()
export class NotesService {
  constructor(
    @InjectRepository(Note)
    private readonly noteRepository: Repository<Note>,
    @InjectRepository(Subject)
    private readonly subjectRepository: Repository<Subject>,
  ) {}

  async create(createNoteDto: CreateNoteDto): Promise<Note> {
    // Verify subject exists
    const subject = await this.subjectRepository.findOne({
      where: { id: createNoteDto.subjectId },
    });

    if (!subject) {
      throw new NotFoundException(
        `Subject with ID ${createNoteDto.subjectId} not found`,
      );
    }

    const note = this.noteRepository.create(createNoteDto);
    return await this.noteRepository.save(note);
  }

  async findAll(subjectId?: string): Promise<Note[]> {
    const queryBuilder = this.noteRepository
      .createQueryBuilder('note')
      .leftJoinAndSelect('note.subject', 'subject')
      .orderBy('note.createdAt', 'DESC');

    if (subjectId) {
      queryBuilder.where('note.subjectId = :subjectId', { subjectId });
    }

    return await queryBuilder.getMany();
  }

  async findOne(id: string): Promise<Note> {
    const note = await this.noteRepository.findOne({
      where: { id },
      relations: ['subject'],
    });

    if (!note) {
      throw new NotFoundException(`Note with ID ${id} not found`);
    }

    return note;
  }

  async update(id: string, updateNoteDto: UpdateNoteDto): Promise<Note> {
    const note = await this.findOne(id);

    // If subjectId is being updated, verify the new subject exists
    if (updateNoteDto.subjectId && updateNoteDto.subjectId !== note.subjectId) {
      const subject = await this.subjectRepository.findOne({
        where: { id: updateNoteDto.subjectId },
      });

      if (!subject) {
        throw new NotFoundException(
          `Subject with ID ${updateNoteDto.subjectId} not found`,
        );
      }
    }

    Object.assign(note, updateNoteDto);
    return await this.noteRepository.save(note);
  }

  async remove(id: string): Promise<void> {
    const note = await this.findOne(id);
    await this.noteRepository.remove(note);
  }
}

