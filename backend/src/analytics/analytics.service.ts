import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThanOrEqual } from 'typeorm';
import { StudySession } from '../study-sessions/entities/study-session.entity';
import { Subject } from '../subjects/entities/subject.entity';
import { SessionStatus } from '../study-sessions/enums/session-status.enum';

export interface DailyStudyData {
    date: string;
    minutes: number;
    sessions: number;
}

export interface SubjectStudyData {
    subjectId: string;
    subjectName: string;
    subjectColor: string;
    totalMinutes: number;
    sessionCount: number;
}

export interface StreakData {
    currentStreak: number;
    longestStreak: number;
    lastStudyDate: string | null;
}

export interface StudySummary {
    totalMinutesToday: number;
    totalMinutesThisWeek: number;
    totalMinutesThisMonth: number;
    totalSessions: number;
    averageSessionMinutes: number;
    mostStudiedSubject: SubjectStudyData | null;
    bestStudyHour: number | null;
}

@Injectable()
export class AnalyticsService {
    constructor(
        @InjectRepository(StudySession)
        private sessionRepository: Repository<StudySession>,
        @InjectRepository(Subject)
        private subjectRepository: Repository<Subject>,
    ) { }

    async getSummary(userId: string): Promise<StudySummary> {
        const now = new Date();
        const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        const startOfWeek = new Date(startOfDay);
        startOfWeek.setDate(startOfWeek.getDate() - startOfWeek.getDay());
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

        // Get all completed sessions for this user
        const allSessions = await this.sessionRepository
            .createQueryBuilder('session')
            .leftJoin('session.subject', 'subject')
            .where('subject.userId = :userId', { userId })
            .andWhere('session.status = :status', { status: SessionStatus.COMPLETED })
            .getMany();

        // Calculate totals
        const todaySessions = allSessions.filter(s => s.startTime && s.startTime >= startOfDay);
        const weekSessions = allSessions.filter(s => s.startTime && s.startTime >= startOfWeek);
        const monthSessions = allSessions.filter(s => s.startTime && s.startTime >= startOfMonth);

        const totalMinutesToday = todaySessions.reduce((sum, s) => sum + s.durationMinutes, 0);
        const totalMinutesThisWeek = weekSessions.reduce((sum, s) => sum + s.durationMinutes, 0);
        const totalMinutesThisMonth = monthSessions.reduce((sum, s) => sum + s.durationMinutes, 0);
        const totalMinutesAll = allSessions.reduce((sum, s) => sum + s.durationMinutes, 0);

        // Get most studied subject
        const subjectStats = await this.getBySubject(userId);
        const mostStudiedSubject = subjectStats.length > 0
            ? subjectStats.reduce((max, s) => s.totalMinutes > max.totalMinutes ? s : max)
            : null;

        // Get best study hour
        const hourCounts: Record<number, number> = {};
        allSessions.forEach(s => {
            if (s.startTime) {
                const hour = s.startTime.getHours();
                hourCounts[hour] = (hourCounts[hour] || 0) + s.durationMinutes;
            }
        });
        const bestStudyHour = Object.keys(hourCounts).length > 0
            ? parseInt(Object.entries(hourCounts).reduce((max, [h, m]) => m > max[1] ? [h, m] : max, ['0', 0])[0])
            : null;

        return {
            totalMinutesToday,
            totalMinutesThisWeek,
            totalMinutesThisMonth,
            totalSessions: allSessions.length,
            averageSessionMinutes: allSessions.length > 0 ? Math.round(totalMinutesAll / allSessions.length) : 0,
            mostStudiedSubject,
            bestStudyHour,
        };
    }

    async getDailyStats(userId: string, days: number = 7): Promise<DailyStudyData[]> {
        const now = new Date();
        const startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate() - days + 1);

        const sessions = await this.sessionRepository
            .createQueryBuilder('session')
            .leftJoin('session.subject', 'subject')
            .where('subject.userId = :userId', { userId })
            .andWhere('session.status = :status', { status: SessionStatus.COMPLETED })
            .andWhere('session.startTime >= :startDate', { startDate })
            .getMany();

        // Group by date
        const dailyData: Record<string, { minutes: number; sessions: number }> = {};

        // Initialize all days with zero
        for (let i = 0; i < days; i++) {
            const date = new Date(startDate);
            date.setDate(date.getDate() + i);
            const dateStr = date.toISOString().split('T')[0];
            dailyData[dateStr] = { minutes: 0, sessions: 0 };
        }

        // Aggregate session data
        sessions.forEach(session => {
            if (session.startTime) {
                const dateStr = session.startTime.toISOString().split('T')[0];
                if (dailyData[dateStr]) {
                    dailyData[dateStr].minutes += session.durationMinutes;
                    dailyData[dateStr].sessions += 1;
                }
            }
        });

        return Object.entries(dailyData).map(([date, data]) => ({
            date,
            minutes: data.minutes,
            sessions: data.sessions,
        })).sort((a, b) => a.date.localeCompare(b.date));
    }

    async getBySubject(userId: string): Promise<SubjectStudyData[]> {
        const results = await this.sessionRepository
            .createQueryBuilder('session')
            .select('session.subjectId', 'subjectId')
            .addSelect('subject.name', 'subjectName')
            .addSelect('subject.color', 'subjectColor')
            .addSelect('SUM(session.durationMinutes)', 'totalMinutes')
            .addSelect('COUNT(session.id)', 'sessionCount')
            .leftJoin('session.subject', 'subject')
            .where('subject.userId = :userId', { userId })
            .andWhere('session.status = :status', { status: SessionStatus.COMPLETED })
            .groupBy('session.subjectId')
            .addGroupBy('subject.name')
            .addGroupBy('subject.color')
            .getRawMany();

        return results.map(r => ({
            subjectId: r.subjectId,
            subjectName: r.subjectName,
            subjectColor: r.subjectColor || '#6366F1',
            totalMinutes: parseInt(r.totalMinutes) || 0,
            sessionCount: parseInt(r.sessionCount) || 0,
        }));
    }

    async getStreaks(userId: string): Promise<StreakData> {
        const sessions = await this.sessionRepository
            .createQueryBuilder('session')
            .leftJoin('session.subject', 'subject')
            .where('subject.userId = :userId', { userId })
            .andWhere('session.status = :status', { status: SessionStatus.COMPLETED })
            .andWhere('session.startTime IS NOT NULL')
            .orderBy('session.startTime', 'DESC')
            .getMany();

        if (sessions.length === 0) {
            return { currentStreak: 0, longestStreak: 0, lastStudyDate: null };
        }

        // Get unique study dates
        const studyDates = [...new Set(
            sessions
                .filter(s => s.startTime)
                .map(s => s.startTime!.toISOString().split('T')[0])
        )].sort().reverse();

        if (studyDates.length === 0) {
            return { currentStreak: 0, longestStreak: 0, lastStudyDate: null };
        }

        const lastStudyDate = studyDates[0];
        const today = new Date().toISOString().split('T')[0];
        const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];

        // Calculate current streak
        let currentStreak = 0;
        let checkDate = lastStudyDate === today || lastStudyDate === yesterday ? new Date(lastStudyDate) : null;

        if (checkDate) {
            for (const dateStr of studyDates) {
                const expectedDate = new Date(checkDate);
                expectedDate.setDate(expectedDate.getDate() - currentStreak);
                const expected = expectedDate.toISOString().split('T')[0];

                if (dateStr === expected) {
                    currentStreak++;
                } else if (currentStreak > 0) {
                    break;
                }
            }
        }

        // Calculate longest streak
        let longestStreak = 0;
        let tempStreak = 1;

        for (let i = 1; i < studyDates.length; i++) {
            const prevDate = new Date(studyDates[i - 1]);
            const currDate = new Date(studyDates[i]);
            const diffDays = Math.round((prevDate.getTime() - currDate.getTime()) / 86400000);

            if (diffDays === 1) {
                tempStreak++;
            } else {
                longestStreak = Math.max(longestStreak, tempStreak);
                tempStreak = 1;
            }
        }
        longestStreak = Math.max(longestStreak, tempStreak);

        return {
            currentStreak,
            longestStreak,
            lastStudyDate,
        };
    }
}
