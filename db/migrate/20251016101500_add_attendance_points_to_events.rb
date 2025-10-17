class AddAttendancePointsToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :attendance_points, :integer, null: false, default: 1
  end
end


