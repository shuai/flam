class CreateCaptions < ActiveRecord::Migration
  def self.up
    create_table :captions do |t|
      t.string :location # location of the resource
      t.string :format # format, not used
      t.string :package # the original package where this resource belongs to
      
      t.timestamps
    end
  end

  def self.down
    drop_table :captions
  end
end
