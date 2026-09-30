import '../models/weekly_schedule_template.dart';
import 'database_service.dart';

class SeedDataService {
  static Future<void> seedWeeklySchedule() async {
    final db = DatabaseService.instance;

    // Check if we already have data
    final existing = await db.getWeeklySchedules();
    if (existing.isNotEmpty) {
      return; // Already seeded
    }

    // Sample weekly schedule with supplements and exercises
    final schedules = [
      // Monday
      WeeklyScheduleTemplate(
        title: 'Morning Supplements',
        category: 'Supplements',
        dayOfWeek: 1,
        plannedTime: '08:00',
        instructions: 'Vitamin D3, Omega-3, Magnesium',
        isOptional: false,
      ),
      WeeklyScheduleTemplate(
        title: 'Resistance Training',
        category: 'Exercise',
        dayOfWeek: 1,
        plannedTime: '17:00',
        instructions: 'Upper body workout - 45 minutes',
        isOptional: false,
      ),
      WeeklyScheduleTemplate(
        title: 'Evening Supplements',
        category: 'Supplements',
        dayOfWeek: 1,
        plannedTime: '20:00',
        instructions: 'Zinc, Vitamin C',
        isOptional: false,
      ),

      // Tuesday
      WeeklyScheduleTemplate(
        title: 'Morning Supplements',
        category: 'Supplements',
        dayOfWeek: 2,
        plannedTime: '08:00',
        instructions: 'Vitamin D3, Omega-3, Magnesium',
        isOptional: false,
      ),
      WeeklyScheduleTemplate(
        title: 'Cardio Session',
        category: 'Exercise',
        dayOfWeek: 2,
        plannedTime: '07:00',
        instructions: 'Zone 2 cardio - 30 minutes',
        isOptional: false,
      ),
      WeeklyScheduleTemplate(
        title: 'Evening Supplements',
        category: 'Supplements',
        dayOfWeek: 2,
        plannedTime: '20:00',
        instructions: 'Zinc, Vitamin C',
        isOptional: false,
      ),

      // Wednesday
      WeeklyScheduleTemplate(
        title: 'Morning Supplements',
        category: 'Supplements',
        dayOfWeek: 3,
        plannedTime: '08:00',
        instructions: 'Vitamin D3, Omega-3, Magnesium',
        isOptional: false,
      ),
      WeeklyScheduleTemplate(
        title: 'Resistance Training',
        category: 'Exercise',
        dayOfWeek: 3,
        plannedTime: '17:00',
        instructions: 'Lower body workout - 45 minutes',
        isOptional: false,
      ),
      WeeklyScheduleTemplate(
        title: 'Evening Supplements',
        category: 'Supplements',
        dayOfWeek: 3,
        plannedTime: '20:00',
        instructions: 'Zinc, Vitamin C',
        isOptional: false,
      ),

      // Thursday
      WeeklyScheduleTemplate(
        title: 'Morning Supplements',
        category: 'Supplements',
        dayOfWeek: 4,
        plannedTime: '08:00',
        instructions: 'Vitamin D3, Omega-3, Magnesium',
        isOptional: false,
      ),
      WeeklyScheduleTemplate(
        title: 'Cardio Session',
        category: 'Exercise',
        dayOfWeek: 4,
        plannedTime: '07:00',
        instructions: 'Zone 2 cardio - 30 minutes',
        isOptional: false,
      ),
      WeeklyScheduleTemplate(
        title: 'Yoga/Stretching',
        category: 'Exercise',
        dayOfWeek: 4,
        plannedTime: '19:00',
        instructions: 'Flexibility routine - 20 minutes',
        isOptional: true,
      ),
      WeeklyScheduleTemplate(
        title: 'Evening Supplements',
        category: 'Supplements',
        dayOfWeek: 4,
        plannedTime: '20:00',
        instructions: 'Zinc, Vitamin C',
        isOptional: false,
      ),

      // Friday
      WeeklyScheduleTemplate(
        title: 'Morning Supplements',
        category: 'Supplements',
        dayOfWeek: 5,
        plannedTime: '08:00',
        instructions: 'Vitamin D3, Omega-3, Magnesium',
        isOptional: false,
      ),
      WeeklyScheduleTemplate(
        title: 'Resistance Training',
        category: 'Exercise',
        dayOfWeek: 5,
        plannedTime: '17:00',
        instructions: 'Full body workout - 45 minutes',
        isOptional: false,
      ),
      WeeklyScheduleTemplate(
        title: 'Evening Supplements',
        category: 'Supplements',
        dayOfWeek: 5,
        plannedTime: '20:00',
        instructions: 'Zinc, Vitamin C',
        isOptional: false,
      ),

      // Saturday
      WeeklyScheduleTemplate(
        title: 'Morning Supplements',
        category: 'Supplements',
        dayOfWeek: 6,
        plannedTime: '09:00',
        instructions: 'Vitamin D3, Omega-3, Magnesium',
        isOptional: false,
      ),
      WeeklyScheduleTemplate(
        title: 'Active Recovery',
        category: 'Exercise',
        dayOfWeek: 6,
        plannedTime: '10:00',
        instructions: 'Light walk or yoga - 30 minutes',
        isOptional: true,
      ),
      WeeklyScheduleTemplate(
        title: 'Evening Supplements',
        category: 'Supplements',
        dayOfWeek: 6,
        plannedTime: '20:00',
        instructions: 'Zinc, Vitamin C',
        isOptional: false,
      ),

      // Sunday
      WeeklyScheduleTemplate(
        title: 'Morning Supplements',
        category: 'Supplements',
        dayOfWeek: 7,
        plannedTime: '09:00',
        instructions: 'Vitamin D3, Omega-3, Magnesium',
        isOptional: false,
      ),
      WeeklyScheduleTemplate(
        title: 'Rest Day Walk',
        category: 'Exercise',
        dayOfWeek: 7,
        plannedTime: '10:00',
        instructions: 'Leisure walk - 20 minutes',
        isOptional: true,
      ),
      WeeklyScheduleTemplate(
        title: 'Evening Supplements',
        category: 'Supplements',
        dayOfWeek: 7,
        plannedTime: '20:00',
        instructions: 'Zinc, Vitamin C',
        isOptional: false,
      ),
    ];

    // Insert all schedules
    for (final schedule in schedules) {
      await db.insertWeeklySchedule(schedule);
    }
  }
}
