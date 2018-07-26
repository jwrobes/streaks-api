class WeeklyStreakGoalWorker
 include Sidekiq::Worker
  def perform(start_date=Date.current)
    start_date = Date.current
    end_date = start_date + 6.days
    last_week_end_date = start_date - 1.day
    last_week_start_date = start_date - 7.days
    new_completion_pct = HabitCompletionPercent.between({
      start_date: last_week_start_date,
      end_date: last_week_end_date
    })

    WeeklyStreakGoal.create({
      completion_percent: new_completion_pct,
      start_date: start_date,
      end_date: end_date
    })
  end
end

