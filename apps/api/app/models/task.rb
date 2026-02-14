class Task < ApplicationRecord
  validates :title, presence: true, length: { minimum: 3 }
  validates :status, presence: true, inclusion: { in: %w[pending doing done]}
end
