class CreatePrograms < ActiveRecord::Migration
  def self.up
    create_table :programs do |t|
      t.string :title #Title of the video
      t.integer :length #Length(in seconds) of the program
      t.references :raw_video
      t.timestamps
    end
  end

  def self.down
    drop_table :programs
  end
end
