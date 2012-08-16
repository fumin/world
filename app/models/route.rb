class Route < ActiveRecord::Base
  attr_accessible :current_service_hash, :password, :username
  validates :username, :password, presence: true
  validates :password, length: {in: 6..20}
end
