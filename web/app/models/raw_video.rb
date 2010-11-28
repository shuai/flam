class RawVideo < ActiveRecord::Base
    has_many :raw_video_streams
    has_many :clips
    has_many :transcoding_tasks
    belongs_to :package
    
end
