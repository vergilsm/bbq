class Event < ActiveRecord::Base

  belongs_to :user

  has_many :comments
  has_many :subscriptions
  # у события много подписчиков (объекты User), через таблицу subscriptions, по ключу user_id
  has_many :subscribers, through: :subscriptions, source: :user
  has_many :photos

  validates :user,     presence: true

  validates :title,    presence: true, length: {maximum: 255}

  validates :address,  presence: true
  validates :datetime, presence: true

  # Метод, который возвращает всех, кто пойдет на событие:
  # всех подписавшихся и организатора
  def visitors
    (subscribers + [user]).uniq
  end

  def pincode_valid?(pin2check)
    pincode == pin2check
  end
end
