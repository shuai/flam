class CreateRawVideoStreams < ActiveRecord::Migration
  def self.up
    create_table :raw_video_streams do |t|
        t.references :raw_video
        
        t.integer :index
        t.string :codec
        t.string :codec_long
        t.string :type
        t.integer :sample_rate
        t.integer :channels
        t.integer :bits_per_sample
        t.integer :avg_framerate
        t.integer :start_time
        t.integer :duration
      
    end
  end

  def self.down
    drop_table :raw_video_streams
  end
end
