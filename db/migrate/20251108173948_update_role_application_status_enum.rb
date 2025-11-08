class UpdateRoleApplicationStatusEnum < ActiveRecord::Migration[8.0]
  def up
    # Update existing 'accepted' status from 2 to 3
    execute 'UPDATE role_applications SET status = 3 WHERE status = 2'

    # Update existing 'rejected' status from 3 to 4
    execute 'UPDATE role_applications SET status = 4 WHERE status = 3'

    # Now status values are:
    # 0: not_reviewed
    # 1: in_review
    # 2: interview_needed (new)
    # 3: accepted (moved from 2)
    # 4: rejected (moved from 3)
  end

  def down
    # Reverse the changes
    execute 'UPDATE role_applications SET status = 2 WHERE status = 3'
    execute 'UPDATE role_applications SET status = 3 WHERE status = 4'
  end
end
