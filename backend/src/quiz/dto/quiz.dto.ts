import { IsString, IsOptional, IsInt, IsArray, Min, Max, IsUUID } from 'class-validator';

export class GenerateQuizDto {
    @IsString()
    content: string;

    @IsString()
    @IsOptional()
    title?: string;

    @IsUUID()
    @IsOptional()
    noteId?: string;

    @IsUUID()
    @IsOptional()
    subjectId?: string;

    @IsInt()
    @Min(3)
    @Max(10)
    @IsOptional()
    numQuestions?: number;
}

export class SubmitAnswerDto {
    @IsUUID()
    questionId: string;

    @IsInt()
    @Min(0)
    @Max(3)
    answerIndex: number;
}

export class SubmitQuizDto {
    @IsArray()
    answers: SubmitAnswerDto[];
}
