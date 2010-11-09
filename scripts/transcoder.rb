#! /usr/bin/env ruby

# Transcode raw videos to bitrates we want

require "mysql"

def getcliplocation(raw_video_id, bitrate)
    "#{Clip_dir}#{raw_video_id}/#{bitrate}.f4v"
end

def transcode(raw_video_location, clip_location, bitrate)
    #TODO here call ffmpeg to transcode
end

def task(id, location, target_bitrate)
    puts "==========================="
    puts "transcode '#{location}'"
    puts "target bitrates #{target_bitrate.join ' '}"
    
    failed_clips = []
    succeed_clips = []

    target_bitrate.each do |bitrate|
        clip_location = getcliplocation id, bitrate
        if transcode(location, clip_location, bitrate)
            $my.query("insert into #{Sql_tbl_clip}(#{Clip_location}, #{Clip_bitrate}, #{Clip_rawvideo}) VALUES(#{clip_location}, #{bitrate}, #{id})")
            succeed_clips << bitrate
        else
            failed_clips << bitrate
        end
    end

    # TODO HERE, update raw_video table
end

if __FILE__ == $0
    $my = Mysql::new(Sql_host, Sql_user, Sql_pswd, Sql_database)

    while true
       res = $my.query("select id,#{Rawvideo_location},#{Rawvideo_needbitrates} from #{Sql_tbl_raw_resource} where #{Rawvideo_needbitrates} is not null")
       res.each do |row|
            location = row[1]
            need_bitrates = row[2].split ","  
            task row[0], location, need_bitrates       
       end
    end
end
