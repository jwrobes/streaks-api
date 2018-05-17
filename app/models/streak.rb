# == Schema Information
#
# Table name: streaks
#
#  id                 :bigint(8)        not null, primary key
#  activated_at       :datetime
#  completed_at       :datetime
#  description        :text
#  ended_at           :datetime
#  habits_per_week    :integer
#  max_habits_per_day :integer          default(1), not null
#  status             :string           default("open"), not null
#  title              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  team_id            :integer
#

class Streak < ApplicationRecord
  belongs_to :team, optional: true
  has_many :streak_players
  has_many :habits
  has_many :players, through: :streak_players, after_add: :notify_on_player_add, after_remove: :notify_on_player_remove

  validates :status, :habits_per_week, :title,  presence: true
  validates_uniqueness_of :team, conditions: -> { where(status: 'active')  }
  validate :minimum_number_of_players_for_active_streak
  validate :minimum_number_of_players_for_open_streak
  validate :team_presence_for_active_streak

  scope :active, -> { where(status: 'active') }
  scope :open, -> { where(status: 'open') }

  around_save :notify_on_save

  attr_reader :listeners

  MIN_PLAYERS = 6

  state_machine :status, initial: :open do
    state :open, :active, :completed

    before_transition any => :active do |streak|
      streak.activated_at = Time.zone.now
    end

    event :activate do
      transition :open => :active
    end

    before_transition any => :complete do |streak|
      streak.completed_at = Time.zone.now
    end

    event :complete do
      transition active: :completed
    end
  end

  def add_listener(listener)
    (@listeners ||= []) << listener
  end

  def notify_listeners(event_name, *args)
    @listeners && @listeners.each do |listener|
      if listener.respond_to?(event_name)
        listener.public_send(event_name, self, *args)
      end
    end
  end

  private

  def minimum_number_of_players_for_active_streak
    if status == "active" && players.count < MIN_PLAYERS
      errors.add(:status, "Unable to activate streak with less than #{MIN_PLAYERS} players")
    end
  end

  def minimum_number_of_players_for_open_streak
    # if status == "open" && players.count < 1
    #   errors.add(:status, "Unable to have an open streak without 1 player")
    # end
  end

  def team_presence_for_active_streak
    if status == "active" && !team
      errors.add(:status, "Unable to activate streak without a team")
    end
  end

  def notify_on_player_add(player)
    old_players_count = players.count - 1
    new_players_count = players.count
    notify_listeners(:player_added, old_players_count, new_players_count, player)
  end

  def notify_on_player_remove(player)
    old_players_count = players.count + 1
    new_players_count = players.count
    notify_listeners(:player_removed, old_players_count, new_players_count, player)
  end

  def notify_on_save
    is_create_save = !persisted?
    old_status = status_was
    status_changed = status_changed?
    yield
    if is_create_save
      notify_listeners(:on_create)
    else
      notify_listeners(:status_changed, old_status, status) if status_changed
    end
  end
end
