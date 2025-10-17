class CheckinsController < ApplicationController
  skip_before_action :ensure_admin_user, raise: false

  def new
    @event = Event.find_signed!(params.require(:token), purpose: 'checkin')
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveSupport::MessageEncryptor::InvalidMessage
    head :gone
  end

  def create
    @event = Event.find_signed!(params.require(:token), purpose: 'checkin')

    unless admin_signed_in?
      redirect_to new_admin_session_path, alert: 'Please sign in to check in.'
      return
    end

    user = User.find_by(google_uid: current_admin.uid)
    if user.nil?
      redirect_to root_path, alert: 'No linked user account found.'
      return
    end

    attendance = Attendance.find_or_initialize_by(user: user, event: @event)
    if attendance.persisted?
      redirect_to root_path, notice: 'You are already checked in for this event.'
      return
    end

    Attendance.transaction do
      attendance.checked_in_at = Time.current
      attendance.save!
      points_to_award = @event.respond_to?(:attendance_points) && @event.attendance_points.present? ? @event.attendance_points : 1
      user.update!(points: user.points + points_to_award)
    end

    redirect_to root_path, notice: 'Checked in! Points awarded.'
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveSupport::MessageEncryptor::InvalidMessage
    head :gone
  end
end


