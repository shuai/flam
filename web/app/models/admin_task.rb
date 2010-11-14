class AdminTask < ActiveRecord::Base

end

class TranscodingTask < AdminTask
    belongs_to :raw_video
    
end

class PackageTask < AdminTask
end
