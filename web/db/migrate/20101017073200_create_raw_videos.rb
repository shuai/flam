class CreateRawVideos < ActiveRecord::Migration
  def self.up
    create_table :raw_videos do |t|
        t.string :title
        t.string :location # S3 or local
        t.string :package  # the original package where this video belongs to
        
        t.integer :status # not used
        t.references :caption # caption to use
    end
  end

  def self.down
    drop_table :raw_videos
  end
end
