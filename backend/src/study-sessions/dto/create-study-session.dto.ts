import {
  IsUUID,
  IsInt,
  Min,
  IsOptional,
  IsDateString,
  IsString,
  IsEnum,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { FocusType } from '../enums/focus-type.enum';
import { SessionStatus } from '../enums/session-status.enum';

export class RecurrenceRuleDto {
  @IsEnum(['WEEKLY', 'DAILY'])
  frequency: 'WEEKLY' | 'DAILY';

  @IsInt({ each: true })
  days?: number[]; // For WEEKLY: [1,3,5] = Mon, Wed, Fri (0=Sun, 1=Mon, etc.)

  @IsDateString()
  until: string; // ISO date string
}

export class CreateStudySessionDto {
  @IsUUID()
  subjectId: string;

  @IsInt()
  @Min(1)
  durationMinutes: number;

  @IsDateString()
  @IsOptional()
  startTime?: string;

  @IsDateString()
  @IsOptional()
  endTime?: string;

  @IsString()
  @IsOptional()
  title?: string;

  @IsEnum(FocusType)
  @IsOptional()
  focusType?: FocusType;

  @IsEnum(SessionStatus)
  @IsOptional()
  status?: SessionStatus;

  @ValidateNested()
  @Type(() => RecurrenceRuleDto)
  @IsOptional()
  recurrenceRule?: RecurrenceRuleDto;
}

