module Resumes
  class IndexQuery
    def self.call(filters = {})
      new(filters).call
    end

    def initialize(filters = {})
      @filters = filters
      @sort = filters[:sort]
      @direction = filters[:direction] == 'desc' ? 'desc' : 'asc'
    end

    def call
      resumes = Resume.includes(:user)
      resumes = apply_filters(resumes)
      apply_sorting(resumes)
    end

    private

    attr_reader :filters, :sort, :direction

    def apply_filters(resumes)
      resumes = apply_basic_filters(resumes)
      apply_gpa_filter(resumes)
    end

    def apply_basic_filters(resumes)
      resumes = resumes.where(major: filters[:major]) if filters[:major].present?
      if filters[:organizational_role].present?
        resumes = resumes.where(organizational_role: filters[:organizational_role])
      end
      resumes = resumes.where(graduation_date: filters[:graduation_year]) if filters[:graduation_year].present?
      resumes
    end

    def apply_gpa_filter(resumes)
      return resumes unless filters[:gpa_value].present? && filters[:gpa_operator].present?

      case filters[:gpa_operator]
      when '>='
        resumes.where('gpa >= ?', filters[:gpa_value].to_f)
      when '<='
        resumes.where('gpa <= ?', filters[:gpa_value].to_f)
      else
        resumes
      end
    end

    def apply_sorting(resumes)
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
