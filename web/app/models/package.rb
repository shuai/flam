class Package < ActiveRecord::Base
    has_many :raw_videos
    has_many :captions
    
end
