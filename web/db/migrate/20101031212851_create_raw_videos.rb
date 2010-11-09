class CreateRawVideos < ActiveRecord::Migration
  def self.up
    create_table :raw_videos do |t|
        t.string :title
        t.string :location # S3 or local
        t.string :package  # the original package where this video belongs to
        
        t.string :need_bitrates # bitrates that we need, separated by ,
        t.string :exist_bitrates # bitrates that exist already, separated by ,

        t.string :status # not used
        t.references :caption # caption to use
    end
  end

  def self.down
    drop_table :raw_videos
  end
end
