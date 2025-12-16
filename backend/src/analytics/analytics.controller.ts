import { Controller, Get, Query, UseGuards, Request } from '@nestjs/common';
import { AnalyticsService } from './analytics.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('analytics')
@UseGuards(JwtAuthGuard)
export class AnalyticsController {
    constructor(private readonly analyticsService: AnalyticsService) { }

    @Get('summary')
    async getSummary(@Request() req) {
        return this.analyticsService.getSummary(req.user.id);
    }

    @Get('daily')
    async getDailyStats(@Request() req, @Query('days') days?: string) {
        const numDays = days ? parseInt(days) : 7;
        return this.analyticsService.getDailyStats(req.user.id, numDays);
    }

    @Get('by-subject')
    async getBySubject(@Request() req) {
        return this.analyticsService.getBySubject(req.user.id);
    }

    @Get('streaks')
    async getStreaks(@Request() req) {
        return this.analyticsService.getStreaks(req.user.id);
    }
}
