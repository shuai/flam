class CreateAdminTasks < ActiveRecord::Migration
  def self.up
    create_table :admin_tasks do |t|

      t.timestamps
      t.string :type     
      t.string :status # new,failed,ing,done
      t.string :err_msg
      t.integer :priority
            
      #transcoding task
      t.references :raw_videos
      t.integer :bitrate
      
      #package task
      t.string :location

    end
  end

  def self.down
    drop_table :admin_tasks
  end
end
