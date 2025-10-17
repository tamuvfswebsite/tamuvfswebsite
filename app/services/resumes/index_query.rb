module Resumes
  class IndexQuery
    def self.call(sort:, direction:)
      direction = direction == 'desc' ? 'desc' : 'asc'

      case sort
      when 'user'
        Resume.joins(:user).includes(:user).order("users.email #{direction}")
      when 'gpa', 'graduation_date', 'major', 'organizational_role'
        Resume.includes(:user).order("#{sort} #{direction}")
      else
        Resume.includes(:user).order(created_at: :desc)
      end
    end
  end
end
