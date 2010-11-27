class CreateRawVideos < ActiveRecord::Migration
  def self.up
    create_table :raw_videos do |t|  
        t.references :package  # the original package where this video belongs to
        
        t.string :location # S3 or local
        
        t.integer :bitrate
        t.string :title
        t.string :format
        t.integer :duration
        t.integer :size
        t.string :author
        t.string :copyright
        t.string :comment 
        
        t.string :status # not used
    end
  end

  def self.down
    drop_table :raw_videos
  end
end
