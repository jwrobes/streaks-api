module AuthenticationHelpers
  def login_as(player)
    allow_any_instance_of(described_class).to receive(:authenticate_request!)
    allow_any_instance_of(described_class).to receive(:current_player).and_return(player)
  end
end
