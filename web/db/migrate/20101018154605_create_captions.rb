class CreateCaptions < ActiveRecord::Migration
  def self.up
    create_table :captions do |t|
      t.references :package # the original package where this resource belongs to

      t.string :location # location of the resource
      t.string :format # format, not used
    end
  end

  def self.down
    drop_table :captions
  end
end
