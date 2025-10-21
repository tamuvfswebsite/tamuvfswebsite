module RoleApplicationsHelper
  def status_badge(status)
    text_map = {
      'not_reviewed' => 'Not Reviewed',
      'in_review' => 'In Review',
      'accepted' => 'Accepted',
      'rejected' => 'Rejected'
    }

    status_text = text_map[status.to_s] || 'Not Reviewed'
    css_class = status.to_s.tr('_', '-')

    content_tag(:span, status_text, class: "status-badge #{css_class}")
  end
end
