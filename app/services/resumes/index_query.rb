module Resumes
  class IndexQuery
    def self.call(sort: nil, direction: nil, major: nil, organizational_role: nil, graduation_year: nil, gpa_operator: nil, gpa_value: nil)
      direction = direction == 'desc' ? 'desc' : 'asc'

      # Start with base query
      resumes = Resume.includes(:user)

      # Apply filters
      resumes = resumes.where(major: major) if major.present?
      resumes = resumes.where(organizational_role: organizational_role) if organizational_role.present?
      resumes = resumes.where(graduation_date: graduation_year) if graduation_year.present?

      # Apply GPA filter with operator
      if gpa_value.present? && gpa_operator.present?
        case gpa_operator
        when '>='
          resumes = resumes.where('gpa >= ?', gpa_value.to_f)
        when '<='
          resumes = resumes.where('gpa <= ?', gpa_value.to_f)
        end
      end

      # Apply sorting
      case sort
      when 'user'
        resumes.joins(:user).order("users.email #{direction}")
      when 'gpa', 'graduation_date', 'major', 'organizational_role'
        resumes.order("#{sort} #{direction}")
      else
        resumes.order(created_at: :desc)
      end
    end
  end
end

