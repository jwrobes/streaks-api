class HabitCompletionPercent

  def self.between(start_date: , end_date:)
    total_possible_habits = 0
    total_completed_habits = 0
    Streak.active.each do |streak|
      possible_habits = streak.habits_projected(start_date: start_date, end_date: end_date)
      completed_habits = streak.habits_completed_count(start_date: start_date, end_date: end_date)
      total_possible_habits += possible_habits
      total_completed_habits += completed_habits
    end
    total_completed_habits.to_f / total_possible_habits
  end
end
