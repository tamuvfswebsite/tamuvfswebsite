class CheckinsController < ApplicationController
  skip_before_action :ensure_admin_user, raise: false

  def new
    @event = Event.find_signed!(params.require(:token), purpose: 'checkin')
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveSupport::MessageEncryptor::InvalidMessage
    head :gone
  end

  def create
    @event = find_event_from_token!

    user = require_member!
    return unless user

    if Attendance.exists?(user: user, event: @event)
      redirect_to root_path, notice: 'You are already checked in for this event.'
      return
    end

    award_points_for_checkin!(user)

    redirect_to root_path, notice: 'Checked in! Points awarded.'
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveSupport::MessageEncryptor::InvalidMessage
    head :gone
  end

  private

  def find_event_from_token!
    Event.find_signed!(params.require(:token), purpose: 'checkin')
  end

  def require_member!
    unless admin_signed_in?
      redirect_to new_admin_session_path, alert: 'Please sign in to check in.'
      return nil
    end

    user = User.find_by(google_uid: current_admin.uid)
    unless user
      redirect_to root_path, alert: 'No linked user account found.'
      return nil
    end

    user
  end

  def award_points_for_checkin!(user)
    Attendance.transaction do
      Attendance.create!(user: user, event: @event, checked_in_at: Time.current)
      user.update!(points: user.points + event_points(@event))
    end
  end

  def event_points(event)
    points = event.respond_to?(:attendance_points) ? event.attendance_points : nil
    points.present? ? points : 1
  end
end
