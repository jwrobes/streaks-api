class TestWorker
 include Sidekiq::Worker

  def perform(start_date=Date.current)
    puts "Current Time is#{Time.zone.now}"
  end
end

