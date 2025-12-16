import { IsString, IsOptional, IsUUID, MaxLength } from 'class-validator';

export class CreateDeckDto {
    @IsString()
    @MaxLength(255)
    name: string;

    @IsString()
    @IsOptional()
    description?: string;

    @IsUUID()
    @IsOptional()
    subjectId?: string;

    @IsString()
    @IsOptional()
    color?: string;
}

export class UpdateDeckDto {
    @IsString()
    @MaxLength(255)
    @IsOptional()
    name?: string;

    @IsString()
    @IsOptional()
    description?: string;

    @IsUUID()
    @IsOptional()
    subjectId?: string;

    @IsString()
    @IsOptional()
    color?: string;
}

export class CreateCardDto {
    @IsString()
    front: string;

    @IsString()
    back: string;
}

export class UpdateCardDto {
    @IsString()
    @IsOptional()
    front?: string;

    @IsString()
    @IsOptional()
    back?: string;
}

export class ReviewCardDto {
    @IsString()
    difficulty: 'easy' | 'medium' | 'hard';

    @IsOptional()
    correct?: boolean;
}
