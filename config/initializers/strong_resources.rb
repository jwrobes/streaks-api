# Define payloads that can be re-used across endpoints.
#
# For instance, you may create Tag objects via the /tags endpoint.
# You may also sidepost Tag objects via the /posts endpoint.
# Here is where the Tag payload can be defined. For example:
#
# strong_resource :tag do
#   attribute :name, :string
#   attribute :active, :boolean
# end
#
# You can now reference this payload across controllers:
#
# class TagsController < ApplicationController
#   strong_resource :tag
# end
#
# class PostsController < ApplicationController
#   strong_resource :post do
#     has_many :tags, disassociate: true, destroy: true
#   end
# end
#
# Custom types can be added here as well:
# Parameters = ActionController::Parameters
# strong_param :pet_type, swagger: :string, type: Parameters.enum('Dog', 'Cat')
#
# strong_resource :pet do
#   attribute :type, :pet_type
# end
#
# For additional documentation, see https://jsonapi-suite.github.io/strong_resources
StrongResources.configure do
  strong_resource :streak do
    attribute :title, :string
    attribute :description, :string
    attribute :habits_per_week, :integer
    attribute :max_habits_per_day, :integer
    attribute :status, :string
    attribute :activated_at, :timestamp
    attribute :completed_at, :timestamp
  end
  strong_resource :streak do
    attribute :title, :string
    attribute :description, :string
    attribute :habits_per_week, :integer
  end
  strong_resource :team do
    attribute :uuid, :string
    attribute :name, :string
    attribute :created_at, :timestamp
  end
  strong_resource :team_player do
    attribute :player_id, :integer
    attribute :team_id, :integer
    attribute :color, :string
  end
  strong_resource :player do
    attribute :user_name, :string
    attribute :uuid, :string
  end
  strong_resource :habit do
    attribute :completed_at, :string
    attribute :streak_id, :integer
    attribute :player_id, :integer
  end
end
