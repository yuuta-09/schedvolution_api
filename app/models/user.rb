# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User
  
  # バリデーション
  validates :name, presence: true, length: { maximum: 50 }
  
  # アソシエーション
  has_many :schedules, dependent: :destroy
end
