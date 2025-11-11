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
      # Join with users table once at the start if needed
      resumes = Resume.includes(:user)
      resumes = resumes.joins(:user) if needs_user_join?
      resumes = apply_filters(resumes)
      apply_sorting(resumes)
    end

    private

    attr_reader :filters, :sort, :direction

    def needs_user_join?
      filters[:search].present? || filters[:organizational_role_id].present?
    end

    def apply_filters(resumes)
      resumes = apply_basic_filters(resumes)
      resumes = apply_gpa_filter(resumes)
      apply_search_filter(resumes)
    end

    def apply_basic_filters(resumes)
      resumes = apply_major_filter(resumes)
      resumes = apply_organizational_role_filter(resumes)
      apply_graduation_year_filter(resumes)
    end

    def apply_search_filter(resumes)
      return resumes unless filters[:search].present?

      # Use the manual search scope which assumes users table is already joined
      resumes.search_by_user(filters[:search])
    end

    def apply_major_filter(resumes)
      return resumes unless filters[:major].present?

      resumes.where(major: filters[:major])
    end

    def apply_organizational_role_filter(resumes)
      return resumes unless filters[:organizational_role_id].present?

      # Don't join again - users table is already joined in call method
      resumes.where(users: { organizational_role_id: filters[:organizational_role_id] })
    end

    def apply_graduation_year_filter(resumes)
      return resumes unless filters[:graduation_year].present?

      resumes.where(graduation_date: filters[:graduation_year])
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
        resumes.joins(:user).order("users.last_name #{direction}, users.first_name #{direction}")
      when 'gpa', 'graduation_date', 'major'
        resumes.order("#{sort} #{direction}")
      when 'organizational_role'
        resumes.joins(user: :organizational_role).order("organizational_roles.name #{direction}")
      else
        resumes.order(created_at: :desc)
      end
    end
  end
end
