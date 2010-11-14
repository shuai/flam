class CreateClips < ActiveRecord::Migration
  def self.up
    create_table :clips do |t|
      t.references :raw_video
      t.string :location #location
      t.integer :duration #length of the clip
      t.integer :bitrate #bitrate
      t.timestamps
    end
  end

  def self.down
    drop_table :clips
  end
end
