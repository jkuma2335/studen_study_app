import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Document } from './entities/document.entity';
import { Subject } from '../subjects/entities/subject.entity';
import { CreateDocumentDto } from './dto/create-document.dto';

@Injectable()
export class DocumentsService {
  constructor(
    @InjectRepository(Document)
    private readonly documentRepository: Repository<Document>,
    @InjectRepository(Subject)
    private readonly subjectRepository: Repository<Subject>,
  ) {}

  async create(createDocumentDto: CreateDocumentDto): Promise<Document> {
    // Verify subject exists
    const subject = await this.subjectRepository.findOne({
      where: { id: createDocumentDto.subjectId },
    });

    if (!subject) {
      throw new NotFoundException(
        `Subject with ID ${createDocumentDto.subjectId} not found`,
      );
    }

    const document = this.documentRepository.create(createDocumentDto);
    return await this.documentRepository.save(document);
  }

  async findAll(): Promise<Document[]> {
    return await this.documentRepository.find({
      relations: ['subject'],
      order: { createdAt: 'DESC' },
    });
  }

  async findBySubject(subjectId: string): Promise<Document[]> {
    // Verify subject exists
    const subject = await this.subjectRepository.findOne({
      where: { id: subjectId },
    });

    if (!subject) {
      throw new NotFoundException(`Subject with ID ${subjectId} not found`);
    }

    return await this.documentRepository.find({
      where: { subjectId },
      relations: ['subject'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Document> {
    const document = await this.documentRepository.findOne({
      where: { id },
      relations: ['subject'],
    });

    if (!document) {
      throw new NotFoundException(`Document with ID ${id} not found`);
    }

    return document;
  }

  async remove(id: string): Promise<void> {
    const document = await this.findOne(id);
    await this.documentRepository.remove(document);
  }
}
