class AddQuestionsToOrganizationalRoles < ActiveRecord::Migration[8.0]
  def change
    add_column :organizational_roles, :question_1, :text
    add_column :organizational_roles, :question_2, :text
    add_column :organizational_roles, :question_3, :text
  end
end
