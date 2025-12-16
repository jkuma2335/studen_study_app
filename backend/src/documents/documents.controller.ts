import {
  Controller,
  Get,
  Post,
  Param,
  Delete,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
  Body,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { DocumentsService } from './documents.service';
import { CreateDocumentDto } from './dto/create-document.dto';

@Controller('documents')
export class DocumentsController {
  constructor(private readonly documentsService: DocumentsService) { }

  @Post('upload')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, cb) => {
          // Generate unique filename: timestamp-random-originalname
          const uniqueSuffix =
            Date.now() + '-' + Math.round(Math.random() * 1e9);
          const ext = extname(file.originalname);
          const filename = `${uniqueSuffix}${ext}`;
          cb(null, filename);
        },
      }),
      limits: {
        fileSize: 10 * 1024 * 1024, // 10MB limit
      },
      fileFilter: (req, file, cb) => {
        // Allow images and PDFs
        const allowedMimes = [
          'image/jpeg',
          'image/png',
          'image/gif',
          'image/webp',
          'application/pdf',
        ];
        if (allowedMimes.includes(file.mimetype)) {
          cb(null, true);
        } else {
          cb(
            new BadRequestException(
              'Invalid file type. Only images and PDFs are allowed.',
            ),
            false,
          );
        }
      },
    }),
  )
  async uploadFile(
    @UploadedFile() file: any,
    @Body('subjectId') subjectId: string,
  ) {
    if (!file) {
      throw new BadRequestException('No file uploaded');
    }

    if (!subjectId) {
      throw new BadRequestException('subjectId is required');
    }

    // Construct the full URL
    const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
    const fileUrl = `${baseUrl}/uploads/${file.filename}`;

    // Create document metadata
    const createDocumentDto: CreateDocumentDto = {
      fileName: file.originalname,
      fileUrl: fileUrl,
      fileType: file.mimetype,
      subjectId: subjectId,
    };

    const document = await this.documentsService.create(createDocumentDto);

    return {
      id: document.id,
      fileName: document.fileName,
      fileUrl: document.fileUrl,
      fileType: document.fileType,
      subjectId: document.subjectId,
      createdAt: document.createdAt,
    };
  }

  @Get()
  findAll() {
    return this.documentsService.findAll();
  }

  @Get('subject/:subjectId')
  findBySubject(@Param('subjectId') subjectId: string) {
    return this.documentsService.findBySubject(subjectId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.documentsService.findOne(id);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.documentsService.remove(id);
  }
}
