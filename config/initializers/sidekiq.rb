## INTIALIZER FOR AWS
rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
 # rails_env = Rails.env || 'development'
 # redis_config = YAML.load_file(rails_root.to_s + '/config/redis.yml')
 # redis_config.merge! redis_config.fetch(Rails.env, {})
 # redis_config.symbolize_keys!
 # Sidekiq.configure_server do |config|
 #    config.redis = { url: "redis://#{redis_config[:host]}:#{redis_config[:port]}/12"  }
 #    schedule_file = "config/schedule.yml"
 #    if File.exist?(schedule_file) && Sidekiq.server?
 #        Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
 #    end
 # end
 # Sidekiq.configure_client do |config|
 #    config.redis = { url: "redis://#{redis_config[:host]}:#{redis_config[:port]}/12"  }
 # end

# INITIALZIER FOR HEROKU
require 'sidekiq'

if Rails.env.production?
  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDISTOGO_URL'] || ENV['REDIS_URL'], size: 1 }
  end

  Sidekiq.configure_server do |config|
    pool_size = ENV['SIDEKIQ_DB_POOL'] || (Sidekiq.options[:concurrency] + 2)
    config.redis = { url: ENV['REDISTOGO_URL'] || ENV['REDIS_URL'], size: pool_size }

    ## configure the redis scheduler
    schedule_file = "config/schedule.yml"
    if File.exist?(schedule_file) && Sidekiq.server?
      Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
    end

    Rails.application.config.after_initialize do
      Rails.logger.info("DB Connection Pool size for Sidekiq Server before disconnect is: #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}")
      ActiveRecord::Base.connection_pool.disconnect!

      ActiveSupport.on_load(:active_record) do
        db_config = Rails.application.config.database_configuration[Rails.env]
        db_config['reaping_frequency'] = ENV['DATABASE_REAP_FREQ'] || 10 # seconds
        db_config['pool'] = pool_size
        ActiveRecord::Base.establish_connection(db_config)
        Rails.logger.info("DB Connection Pool size for Sidekiq Server is now: #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}")
      end
    end
  end
else
  rails_env = 'development'
  redis_config = YAML.load_file(rails_root.to_s + '/config/redis.yml')
  redis_config.merge! redis_config.fetch(Rails.env, {})
  redis_config.symbolize_keys!
  Sidekiq.configure_server do |config|
    config.redis = { url: "redis://#{redis_config[:host]}:#{redis_config[:port]}/12"  }
    schedule_file = "config/schedule.yml"
    if File.exist?(schedule_file) && Sidekiq.server?
      Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
    end
  end
  Sidekiq.configure_client do |config|
    config.redis = { url: "redis://#{redis_config[:host]}:#{redis_config[:port]}/12"  }
  end
end
