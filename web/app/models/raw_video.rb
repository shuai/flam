class RawVideo < ActiveRecord::Base
    has_many :raw_video_streams
    belongs_to :package
    
end
