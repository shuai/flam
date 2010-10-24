class CreateVideoResources < ActiveRecord::Migration
  def self.up
    create_table :video_resources do |t|
      t.references :raw_video
      t.string :location #notice the location could be local or on s3
      t.integer :bitrate #bitrate of the clip
    end
  end

  def self.down
    drop_table :video_resources
  end
end
