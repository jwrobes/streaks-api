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

require 'rails_helper'

describe Streak, type: :model do

  it { is_expected.to belong_to(:team) }
  it { is_expected.to have_many(:players).through(:streak_players) }
  it { is_expected.to have_many(:habits) }

  it { is_expected.to validate_presence_of(:status) }

  describe "scopes" do
    describe ".open" do
      it "returns only open  streaks" do
        team = create(:team)
        players = Streak::MIN_PLAYERS.times.map { create(:player) }
        players.each { |player| team.players << player }
        active_streak = build(:streak, :open, team: team)
        players.each { |player| active_streak.players << player }
        active_streak.save
        active_streak.activate!
        open_streak = create(:streak, players: [create(:player)])

        expect(described_class.open.count).to eq(1)
        expect(described_class.open.first).to eq(open_streak)
      end
    end

    describe ".active" do
      it "returns only active streaks" do
        team = create(:team)
        players = Streak::MIN_PLAYERS.times.map { create(:player) }
        players.each { |player| team.players << player }
        active_streak = build(:streak, :open, team: team)
        players.each { |player| active_streak.players << player }
        active_streak.save

        active_streak.activate!
        create(:streak, :open)

        expect(described_class.active.count).to eq(1)
        expect(described_class.active.first).to eq(active_streak)
      end
    end
  end

  describe "when a player joins a streak and it would activate a second streak for a team" do
    xit "is expected to be invalid" do
      # create active streak
      active_streak = create(:streak, :active)
      active_streak.reload
      open_streak = create(:streak, :open)
      new_player = active_streak.players.first
      open_streak.players << active_streak.players.last(5)

      expect{open_streak.players << new_player}.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "#activate!" do
    context "with streak with less than players" do
      it "is expected to raise state transition error" do
        streak = FactoryBot.create(:streak)
        expect { streak.activate! }.to raise_error(StateMachines::InvalidTransition)
      end
    end

    context "with a streak with minimum required players" do
      context "with a team associated" do
        it "is expected to transition streak to active" do
          team = create(:team)
          players = Streak::MIN_PLAYERS.times.map { create(:player) }
          players.each { |player| team.players << player }
          streak = create(:streak, team: team)
          players.each { |player| streak.players << player }

          expect { streak.activate! }.to change { streak.status }.from("open").to("active")
        end

        it "is expected to set started_at" do
          team = create(:team)
          players = Streak::MIN_PLAYERS.times.map { create(:player) }
          players.each { |player| team.players << player }
          streak = create(:streak, team: team)
          players.each { |player| streak.players << player }

          Streak::MIN_PLAYERS.times { streak.players << create(:player) }

          expect { streak.activate! }.to change { streak.activated_at }.from(nil)
        end
      end

      context "with no team associated" do
        it "is expected to raise state transition error" do
          streak = create(:streak)
          players = Streak::MIN_PLAYERS.times.map { create(:player) }
          players.each { |player| streak.players << player }
          expect { streak.activate! }.to raise_error(StateMachines::InvalidTransition)
        end
      end
    end
  end

  context "when a player tries to add more than the max daily habits in a day" do
    it "does not save habit" do
      streak = create(:streak, :active, max_habits_per_day: 1)
      player = streak.players.first
      second_habit_completed_time = Time.zone.now

      first_habit_on_day = create(:habit, streak: streak, player: player, completed_at: second_habit_completed_time - 1.hour)
      second_habit_on_day = build(:habit, streak: streak, player: player, completed_at: second_habit_completed_time)
      second_habit_on_day.save
      expect(second_habit_on_day).to be_invalid
    end

    xit "adds errors to the streak" do
      streak = create(:streak, :active, max_habits_per_day: 1)
      player = streak.players.first
      second_habit_completed_time = Time.zone.now

      first_habit_on_day = create(:habit, streak: streak, player: player, completed_at: second_habit_completed_time - 1.hour)
      second_habit_on_day = build(:habit, streak: streak, player: player, completed_at: second_habit_completed_time)
      second_habit_on_day.save

      expect(second_habit_on_day.errors).to be_present
    end
  end

  describe "#add_listeners" do
    it "adds object to listeners" do
      mock_object = double()
      streak = create(:streak)

      streak.add_listener(mock_object)
      expect(streak.listeners).to include(mock_object)
    end
  end

  describe "#notify_listeners" do
    it "notify listeners of event" do
      # add a mock listener
      mock_object = double
      streak = create(:streak)
      streak.add_listener(mock_object)

      test_arg = 'holy moly'
      expect(mock_object).to receive(:test_event).with(streak, test_arg)

      streak.notify_listeners(:test_event, test_arg)
    end

    context "when status has changed from open to active" do
      it "notifies listeners that status changed" do
        #set up object that listens to status changed
        mock_object = double
        allow(mock_object).to receive(:status_changed)

        # set up streak that has team and players required to transition from open to active
        team = create(:team)
        players = Streak::MIN_PLAYERS.times.map { create(:player) }
        players.each { |player| team.players << player }
        streak = create(:streak, team: team)
        players.each { |player| streak.players << player }

        # add mock object as listener to streak
        streak.add_listener(mock_object)
        expect(mock_object).to receive(:status_changed).with(streak, "open", "active")

        #change streak from open to active
        streak.activate!
      end
    end

    context "when there is a new player added to a streak" do
      it "notifies listeners that new player has been added" do
        #set up object that listens to a players_changed
        mock_object = double
        allow(mock_object).to receive(:player_added)

        # set up streak that has one player
        streak = create(:streak)
        streak.players << create(:player)
        streak.save

        # add mock object as listener to streak
        new_player = create(:player)
        streak.add_listener(mock_object)

        #expect that mock object receive player_added notification
        expect(mock_object).to receive(:player_added).with(streak, 1, 2, new_player)

        #expect that players for streak is 1
        expect(StreakPlayer.where(streak_id: streak.id).count).to eq(1)

        #Add one player to streak and save
        streak.players << new_player

        #expect that players for streak is 2
        expect(StreakPlayer.where(streak_id: streak.id).count).to eq(2)
      end
    end

    context "when there is a player removed from a streak" do
      it "notifies listeners that player has been removed" do
        #set up object that listens to a players_changed
        mock_object = double
        allow(mock_object).to receive(:player_removed)

        # set up streak that has one player
        streak = create(:streak)
        streak.players << create(:player)
        player_to_remove = create(:player)
        streak.players << player_to_remove

        # add mock object as listener to streak
        streak.add_listener(mock_object)

        #expect that mock object receive player_added notification
        expect(mock_object).to receive(:player_removed).with(streak, 2, 1, player_to_remove)

        #expect that players for streak is 2
        expect(StreakPlayer.where(streak_id: streak.id).count).to eq(2)

        #Add one player to streak and save
        streak.players.delete(player_to_remove)

        #expect that players for streak is 1
        expect(StreakPlayer.where(streak_id: streak.id).count).to eq(1)
      end
    end
  end
end

