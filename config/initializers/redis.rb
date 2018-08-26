# Setup the redis for heroku and tests
rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
rails_env = Rails.env || 'development'
redis_config = YAML.load_file(rails_root.to_s + '/config/redis.yml')
redis_config.merge! redis_config.fetch(Rails.env, {})
redis_config.symbolize_keys!
redis_uri = ENV["REDISTOGO_URL"] || "redis://#{redis_config[:host]}:#{redis_config[:port]}/12"
uri = URI.parse(redis_uri)
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
