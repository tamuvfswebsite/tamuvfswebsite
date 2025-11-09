module EventsHelper
  def event_target_roles_display(event)
    if event.is_public?
      'Public (Everyone)'
    elsif event.organizational_roles.any?
      event.organizational_roles.pluck(:name).join(', ')
    else
      'All Roles'
    end
  end

  def event_relevant_to_user?(event, user_roles)
    return true if event.is_public?

    # Events with no specific roles are only relevant to users WITH roles
    return user_roles.any? if event.organizational_roles.empty?

    return false if user_roles.empty?

    (event.organizational_roles & user_roles).any?
  end

  def event_tag_badge(event)
    if event.is_public?
      content_tag(:span, 'Public', class: 'badge badge-public')
    elsif event.organizational_roles.any?
      event.organizational_roles.map do |role|
        content_tag(:span, role.name, class: 'badge badge-role')
      end.join(' ').html_safe
    else
      content_tag(:span, 'All Roles', class: 'badge badge-all')
    end
  end
end
