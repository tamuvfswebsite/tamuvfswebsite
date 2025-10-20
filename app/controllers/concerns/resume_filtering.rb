# frozen_string_literal: true

module ResumeFiltering
  extend ActiveSupport::Concern

  private

  def fetch_filtered_resumes
    per_page = [(params[:per] || 20).to_i, 100].min
    Resumes::IndexQuery.call(build_filter_params).page(params[:page]).per(per_page)
  end

  def build_filter_params
    {
      sort: params[:sort],
      direction: params[:direction],
      major: params[:major],
      organizational_role: params[:organizational_role],
      graduation_year: params[:graduation_year],
      gpa_operator: params[:gpa_operator],
      gpa_value: params[:gpa_value]
    }
  end

  def load_filter_options
    @majors = Resume.where.not(major: [nil, '']).distinct.pluck(:major).sort
    @organizational_roles = Resume.where.not(organizational_role: [nil, '']).distinct.pluck(:organizational_role).sort
    @graduation_years = Resume.where.not(graduation_date: nil).distinct.pluck(:graduation_date).sort.reverse
  end
end
