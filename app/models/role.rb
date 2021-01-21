class Role < ApplicationRecord
    has_many :players
    has_many :users
end
