class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :events
  has_many :comments

  validates :name, presence: true, length: {maximum: 35}

  # перед валидацией задать новое имя :set_name только при создании
  before_validation :set_name, on: :create

  private

  # задаем юзеру случайное имя, если оно пустое
  def set_name
    self.name = I18n.t('activerecord.models.user') if self.name.blank?
  end

end
