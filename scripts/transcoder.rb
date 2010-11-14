#! /usr/bin/env ruby

# Transcode raw videos to bitrates we want

require "mysql"
require "common.rb"

class Task
    attr_accessor :VideoID, :Location, :Bitrate

    def initialize(id,location,bitrate)
        @VideoID = id
        @Location = location
        @Bitrate = bitrate

    end
    
    def start
        puts "==========================="
        puts "transcoding '#{location}' target bitrates #{target_bitrate}"
        
        if transcode?
            $my.query("insert into #{Sql_tbl_clip}(location,duration,bitrate) values('#{getcliplocation}',0,#{@bitrate});")
            set_status "done"
        else
            set_status "failed"
        end
        
    end
    
    def set_status(status)
        $my.query("update #{Sql_tbl_task} set status=#{status} where id = #{@VideoID};")
    end
    
    def getcliplocation
    "#{Clip_dir}#{@VideoID}/#{@Bitrate}.f4v"
    end
    
    def transcode
        #TODO here call ffmpeg to transcode
        IO.popen("ffmpeg -i #{@Location} -vcodec libx264 -acodec libfaac #{dest_location}}")
    end

end

if __FILE__ == $0

    while true
       $my = Mysql::new(Sql_host, Sql_user, Sql_pswd, Sql_database)

       sql = ("select r.id,r.location,t.parameter,t.type,t.status,t.priority from #{Sql_tbl_raw_resource} as r, #{Sql_tbl_task} as t " +
               "where r.id = t.raw_videos_id and t.type = 'transcode' and t.status = 'new' " +
               "order by t.priority limit 5")
                       
       res = $my.query(sql)
       res.each do |row|
            task = Task.new row[0], row[1], row[2]
            task.start
       end
       
       $my = nil

       puts "idling"
       sleep 10
    end
end
