class AddDetailsToResume < ActiveRecord::Migration[8.0]
  def change
    add_column :resumes, :gpa, :float
    add_column :resumes, :graduation_date, :integer
    add_column :resumes, :major, :string
    add_column :resumes, :organizational_role, :string
  end
end
