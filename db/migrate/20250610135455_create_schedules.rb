class CreateSchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :schedules do |t|
      t.string :title, null: false
      t.text :description, null: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.datetime :started_at, null: true
      t.datetime :ended_at, null: true
      t.datetime :remind_at, null: true
      t.string :location, null: true
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 5
      t.integer :user_id, null: false, foreign_key: true
      t.boolean :all_day, default: false, null: false
      t.timestamps
    end
  end
end
