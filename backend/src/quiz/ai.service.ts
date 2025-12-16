import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

interface GeneratedQuestion {
    question: string;
    options: string[];
    correctOptionIndex: number;
    explanation: string;
}

@Injectable()
export class AiService {
    private readonly logger = new Logger(AiService.name);
    private readonly geminiApiKey: string;
    private readonly openAiApiKey: string;

    constructor(private configService: ConfigService) {
        this.geminiApiKey = this.configService.get<string>('GEMINI_API_KEY') || '';
        this.openAiApiKey = this.configService.get<string>('OPENAI_API_KEY') || '';
    }

    async generateQuizFromContent(content: string, numQuestions: number = 5): Promise<GeneratedQuestion[]> {
        // Preference: OpenAI -> Gemini -> Fallback
        const providers = ['openai', 'gemini'];

        for (const provider of providers) {
            try {
                if (provider === 'openai') {
                    if (!this.openAiApiKey) continue;
                    this.logger.log('Attempting to generate quiz using OpenAI...');
                    return await this.generateWithOpenAi(content, numQuestions);
                } else if (provider === 'gemini') {
                    if (!this.geminiApiKey) continue;
                    this.logger.log('Attempting to generate quiz using Gemini...');
                    return await this.generateWithGemini(content, numQuestions);
                }
            } catch (error) {
                this.logger.error(`Provider ${provider} failed: ${error.message}`);
                // Continue to next provider
            }
        }

        this.logger.error('All AI providers failed, returning fallback.');
        return this.generateFallbackQuestions(content, numQuestions);
    }

    private async generateWithOpenAi(content: string, numQuestions: number): Promise<GeneratedQuestion[]> {
        const prompt = `Role
You are an intelligent study assistant embedded in a student study app. Your job is to generate high-quality quiz questions strictly from the user’s notes.

Input
Study notes provided below.
Number of questions: ${numQuestions}

Instructions
- Use only the provided notes. Do not introduce external information.
- Generate meaningful learning-focused questions (Prioritize understanding, application, and recall).
- Avoid vague or trick questions.
- Match the requested difficulty level: Intermediate (explanations, comparisons, examples).
- Ensure clarity and correctness. Each question must have one correct answer.

Output Format (STRICT)
Return ONLY a valid JSON array with this exact structure, no markdown or extra text:
[
  {
    "question": "Question text",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctOptionIndex": 0,
    "explanation": "Brief explanation based on the notes"
  }
]

Requirements:
- Each question must have exactly 4 options.
- correctOptionIndex must be 0, 1, 2, or 3.
- Questions should test comprehension, not just recall.
- Make questions progressively harder.
- Keep explanations concise and directly tied to the notes.

Quality Rules
- Do not include emojis.
- Do not include markdown formatting.
- Do not include commentary outside the JSON.
- Ensure the quiz feels like it was written by a professional educator.

CONTENT:
${content}`;

        const response = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${this.openAiApiKey}`,
            },
            body: JSON.stringify({
                model: 'gpt-3.5-turbo', // Cost-effective and fast
                messages: [
                    { role: 'system', content: 'You are a helpful AI study assistant that generates quizzes in strict JSON format.' },
                    { role: 'user', content: prompt }
                ],
                temperature: 0.7,
            }),
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`OpenAI API error (${response.status}): ${errorText}`);
        }

        const data = await response.json();
        const textContent = data.choices?.[0]?.message?.content;

        if (!textContent) {
            throw new Error('No content in OpenAI response');
        }

        return this.parseQuizJson(textContent, numQuestions);
    }

    private async generateWithGemini(content: string, numQuestions: number): Promise<GeneratedQuestion[]> {
        const model = 'gemini-2.5-flash';

        for (let attempt = 1; attempt <= 3; attempt++) {
            try {
                this.logger.log(`Attempting Gemini model ${model} (Attempt ${attempt}/3)...`);
                const textContent = await this.callGeminiModel(model, content, numQuestions);
                const questions = this.parseQuizJson(textContent, numQuestions);
                if (questions.length > 0) return questions;
            } catch (error) {
                this.logger.warn(`Gemini Attempt ${attempt} failed: ${error.message}`);

                if (attempt < 3) {
                    const match = error.message.match(/retry in (\d+)/);
                    let delay = 3000 * Math.pow(2, attempt - 1);
                    if (match && match[1]) delay = (parseInt(match[1]) + 1) * 1000;

                    this.logger.log(`Waiting ${delay}ms before next attempt...`);
                    await new Promise(resolve => setTimeout(resolve, delay));
                }
            }
        }
        throw new Error('All Gemini retry attempts failed');
    }

    private async callGeminiModel(model: string, content: string, numQuestions: number): Promise<string> {
        const response = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${this.geminiApiKey}`,
            {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    contents: [{
                        parts: [{
                            text: `Role
You are an intelligent study assistant embedded in a student study app. Your job is to generate high-quality quiz questions strictly from the user’s notes.

Input
Study notes provided below.
Number of questions: ${numQuestions}

Instructions
- Use only the provided notes. Do not introduce external information.
- Generate meaningful learning-focused questions (Prioritize understanding, application, and recall).
- Avoid vague or trick questions.
- Match the requested difficulty level: Intermediate (explanations, comparisons, examples).
- Ensure clarity and correctness. Each question must have one correct answer.

Output Format (STRICT)
Return ONLY a valid JSON array with this exact structure, no markdown or extra text:
[
  {
    "question": "Question text",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctOptionIndex": 0,
    "explanation": "Brief explanation based on the notes"
  }
]

Requirements:
- Each question must have exactly 4 options.
- correctOptionIndex must be 0, 1, 2, or 3.
- Questions should test comprehension, not just recall.
- Make questions progressively harder.
- Keep explanations concise and directly tied to the notes.

Quality Rules
- Do not include emojis.
- Do not include markdown formatting.
- Do not include commentary outside the JSON.
- Ensure the quiz feels like it was written by a professional educator.

CONTENT:
${content}`
                        }]
                    }],
                    generationConfig: {
                        temperature: 0.7,
                        maxOutputTokens: 2048,
                    },
                }),
            },
        );

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Gemini API error (${response.status}): ${errorText}`);
        }

        const data = await response.json();
        const textContent = data.candidates?.[0]?.content?.parts?.[0]?.text;

        if (!textContent) {
            throw new Error('No content in Gemini response');
        }

        return textContent;
    }

    private parseQuizJson(textContent: string, numQuestions: number): GeneratedQuestion[] {
        // Extract JSON from response (handle markdown code blocks)
        let jsonStr = textContent;
        const jsonMatch = textContent.match(/```(?:json)?\s*([\s\S]*?)```/);
        if (jsonMatch) {
            jsonStr = jsonMatch[1].trim();
        }

        try {
            const questions: GeneratedQuestion[] = JSON.parse(jsonStr);
            // Validate structure
            return questions.filter(q =>
                q.question &&
                Array.isArray(q.options) &&
                q.options.length === 4 &&
                typeof q.correctOptionIndex === 'number' &&
                q.correctOptionIndex >= 0 &&
                q.correctOptionIndex <= 3
            ).slice(0, numQuestions);
        } catch (e) {
            throw new Error(`Failed to parse AI response as JSON: ${e.message}`);
        }
    }

    private generateFallbackQuestions(content: string, numQuestions: number): GeneratedQuestion[] {
        // Simple fallback: create basic comprehension questions
        const words = content.split(/\s+/).filter(w => w.length > 4);
        const questions: GeneratedQuestion[] = [];

        for (let i = 0; i < Math.min(numQuestions, 3); i++) {
            const randomWord = words[Math.floor(Math.random() * words.length)] || 'topic';
            questions.push({
                question: `What is the main concept discussed regarding "${randomWord.replace(/[^\w]/g, '')}"?`,
                options: [
                    'It is a fundamental concept in this topic',
                    'It is not relevant to the discussion',
                    'It contradicts the main theory',
                    'It is only mentioned briefly',
                ],
                correctOptionIndex: 0,
                explanation: 'This is a fallback question. Please configure GEMINI_API_KEY for AI-generated questions.',
            });
        }

        return questions;
    }
}
