class Schedule < ApplicationRecord
  # バリデーション
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :location, length: { maximum: 255 }
  validates :status, presence: true
  validates :priority, presence: true
  validates :user_id, presence: true
  validates :all_day, inclusion: { in: [true, false] }

  # アソシエーション
  belongs_to :user

  # スコープ
  scope :upcoming, -> { where('start_time >= ?', Time.current) }
  scope :past, -> { where('end_time < ?', Time.current) }
  scope :today, -> { where(start_time: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_max_priority, ->(priority) { where('priority <= ?', priority) }
  scope :by_min_priority, ->(priority) { where('priority >= ?', priority) }

  # 定数
  enum status: { pending: 0, processing: 1, succeeded: 2, failed: 3, canceled: 4 }
end
