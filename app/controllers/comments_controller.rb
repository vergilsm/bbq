class CommentsController < ApplicationController
  before_action :set_event,   only: [:create, :destroy]
  before_action :set_comment, only: [:destroy]

  # POST /comments
  def create
    @new_comment = @event.comments.build(comment_params)
    @new_comment.user = current_user

    if @new_comment.save
      # уведомляем всех подписчиков о новом комментарии
      notify_subscribers(@event, @new_comment)

      # если сохранился успешно, редирект на страницу самого события
      redirect_to @event, notice: I18n.t('controllers.comments.created')
    else
      # если ошибки — рендерим здесь же шаблон события
      render 'events/show', alert: I18n.t('controllers.comments.error')
    end
  end

  # DELETE /comments/1
  def destroy
    message = {notice: I18n.t('controllers.comments.destroyed')}

    if current_user_can_edit?(@comment)
      @comment.destroy!
    else
      message = {alert: I18n.t('controllers.comment.error')}
    end

    redirect_to @event, message
  end

  private
  def set_event
    @event = Event.find(params[:event_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = @event.comments.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def comment_params
    params.require(:comment).permit(:body, :user_name)
  end

  def notify_subscribers(event, comment)
    # собираем всех подписчиков и автора события в массив мэйлов, исключаем повторяющиеся
    all_emails = (event.subscriptions.map(&:user_email) + [event.user.email]).uniq

    # Автору комментария, письмо с не отправляется
    if comment.user.present?
      all_emails.delete(comment.user.email)
    end

    # XXX: Этот метод может выполняться долго из-за большого числа подписчиков
    # поэтому в реальных приложениях такие вещи надо выносить в background задачи!
    all_emails.each do |mail|
      EventMailer.comment(event, comment, mail).deliver_now
    end
  end
end
