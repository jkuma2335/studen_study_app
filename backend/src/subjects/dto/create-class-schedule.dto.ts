import { IsString, IsNotEmpty, IsOptional, Matches } from 'class-validator';

export class CreateClassScheduleDto {
  @IsString()
  @IsNotEmpty()
  @Matches(/^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)$/i, {
    message: 'dayOfWeek must be one of: Mon, Tue, Wed, Thu, Fri, Sat, Sun',
  })
  dayOfWeek: string;

  @IsString()
  @IsNotEmpty()
  @Matches(/^([0-1][0-9]|2[0-3]):[0-5][0-9]$/, {
    message: 'startTime must be in HH:mm format (e.g., 09:00, 14:30)',
  })
  startTime: string;

  @IsString()
  @IsNotEmpty()
  @Matches(/^([0-1][0-9]|2[0-3]):[0-5][0-9]$/, {
    message: 'endTime must be in HH:mm format (e.g., 10:30, 16:00)',
  })
  endTime: string;

  @IsString()
  @IsOptional()
  location?: string;
}

