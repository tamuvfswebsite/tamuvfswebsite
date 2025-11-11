module AdminPanel
  class SponsorUserAssigner
    def initialize(sponsor, user_ids)
      @sponsor = sponsor
      @user_ids = Array(user_ids).reject(&:blank?).map(&:to_i)
    end

    def call
      ActiveRecord::Base.transaction do
        clear_existing_assignments
        assign_selected_users
        assign_unassigned_sponsor_users
      end
    end

    private

    def clear_existing_assignments
      @sponsor.users.find_each { |u| u.sponsors.clear }
    end

    def assign_selected_users
      return if @user_ids.empty?

      User.where(id: @user_ids, role: 'sponsor').find_each do |user|
        user.sponsors.clear
        user.sponsors << @sponsor
      end
    end

    def assign_unassigned_sponsor_users
      default = Sponsor.default_sponsor
      User.where(role: 'sponsor')
          .left_joins(:sponsors)
          .where(sponsors: { id: nil })
          .find_each { |u| u.sponsors << default }
    end
  end
end
