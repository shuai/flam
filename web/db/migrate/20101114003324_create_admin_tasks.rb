class CreateAdminTasks < ActiveRecord::Migration
  def self.up
    create_table :admin_tasks do |t|

      t.timestamps


      t.references :raw_videos
      t.string :type
      t.string :parameter
      t.string :status
      t.integer :priority
      
    end
  end

  def self.down
    drop_table :admin_tasks
  end
end
