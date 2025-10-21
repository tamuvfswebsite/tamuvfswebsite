class SeedOrganizationalRoles < ActiveRecord::Migration[7.2]
  def up
    OrganizationalRole.create([
                                { name: 'AI Team' },
                                { name: 'Design Team' }
                              ])
  end

  def down
    OrganizationalRole.where(name: ['AI Team', 'Design Team']).destroy_all
  end
end
