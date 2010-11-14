class CreateAdminTasks < ActiveRecord::Migration
  def self.up
    create_table :admin_tasks do |t|

      t.timestamps
      t.string :type     
      t.string :status
      t.integer :priority
            
      #Transcoding task
      t.integer :raw_videos_id
      t.integer :bitrate
      
      #package task
      t.string :location

    end
  end

  def self.down
    drop_table :admin_tasks
  end
end
