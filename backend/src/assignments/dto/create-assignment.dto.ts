import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsEnum,
  IsUUID,
  IsDateString,
  IsArray,
  IsUrl,
} from 'class-validator';
import {
  AssignmentPriority,
  AssignmentStatus,
} from '../entities/assignment.entity';

export class CreateAssignmentDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsDateString()
  @IsNotEmpty()
  dueDate: string;

  @IsEnum(AssignmentStatus)
  @IsOptional()
  status?: AssignmentStatus;

  @IsEnum(AssignmentPriority)
  @IsOptional()
  priority?: AssignmentPriority;

  @IsArray()
  @IsOptional()
  @IsUrl({}, { each: true })
  attachmentUrls?: string[];

  @IsUUID()
  @IsNotEmpty()
  subjectId: string;
}

