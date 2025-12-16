import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsNumber,
  Min,
  Matches,
  IsEmail,
  IsArray,
  ValidateNested,
  IsIn,
} from 'class-validator';
import { Type } from 'class-transformer';
import { CreateClassScheduleDto } from './create-class-schedule.dto';

export class CreateSubjectDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  @Matches(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/, {
    message: 'color must be a valid hex color code (e.g., #3B82F6 or #FFF)',
  })
  color?: string;

  @IsString()
  @IsOptional()
  teacherName?: string;

  @IsString()
  @IsOptional()
  @IsEmail({}, { message: 'teacherEmail must be a valid email address' })
  teacherEmail?: string;

  @IsString()
  @IsOptional()
  teacherPhone?: string;

  @IsNumber()
  @IsOptional()
  @Min(0)
  studyGoalHours?: number;

  @IsString()
  @IsOptional()
  category?: string; // e.g., 'Science', 'Arts', 'Math'

  @IsString()
  @IsOptional()
  @IsIn(['Easy', 'Medium', 'Hard'], {
    message: 'difficulty must be one of: Easy, Medium, Hard',
  })
  difficulty?: string;

  @IsArray()
  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => CreateClassScheduleDto)
  schedules?: CreateClassScheduleDto[];
}

