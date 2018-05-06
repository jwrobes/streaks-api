# == Schema Information
#
# Table name: players
#
#  id         :bigint(8)        not null, primary key
#  user_name  :string
#  uuid       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_players_on_user_name  (user_name) UNIQUE
#  index_players_on_uuid       (uuid) UNIQUE
#

require 'rails_helper'

RSpec.describe Player, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
