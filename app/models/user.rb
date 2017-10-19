class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :events
  has_many :comments
  has_many :subscriptions

  validates :name, presence: true, length: {maximum: 35}

  # перед валидацией задать новое имя :set_name только при создании
  before_validation :set_name, on: :create

  after_commit :link_subscriptions, on: :create

  mount_uploader :avatar, AvatarUploader

  private
  # задаем юзеру случайное имя, если оно пустое
  def set_name
    self.name = I18n.t('activerecord.models.user') if self.name.blank?
  end

  def link_subscriptions
    Subscription.where(user_id: nil, user_email: self.email).update_all(user_id: self.id)
  end
end
