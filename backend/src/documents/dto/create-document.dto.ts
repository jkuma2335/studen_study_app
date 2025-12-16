import { IsString, IsUUID } from 'class-validator';

export class CreateDocumentDto {
  @IsString()
  fileName: string;

  @IsString()
  fileUrl: string;

  @IsString()
  fileType: string;

  @IsUUID()
  subjectId: string;
}
