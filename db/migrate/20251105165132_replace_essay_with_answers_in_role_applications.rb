class ReplaceEssayWithAnswersInRoleApplications < ActiveRecord::Migration[8.0]
  def change
    remove_column :role_applications, :essay, :text
    add_column :role_applications, :answer_1, :text
    add_column :role_applications, :answer_2, :text
    add_column :role_applications, :answer_3, :text
  end
end
