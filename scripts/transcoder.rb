#! /usr/bin/env ruby

# Transcode raw videos to bitrates we want

require "mysql"
require "common.rb"
require "models.rb"

def run_task(task)
    puts "==========================="
    puts "transcoding '#{task.raw_video.location}' target bitrates #{task.bitrate}"
    
    source = task.raw_video.location
    dest = getcliplocation(task.raw_videos_id, task.bitrate)
    
    if transcode?(source, dest, task.bitrate)
        clip = Video.new 
        if clip.is_video?
            record = Clip.new(:location => clip_path, :bitrate => clip.Bitrate, :duration => clip.Duration)
            if record.save
                task.status = "done"
            end
        end
    end
    
    if task.status == "new"
        task.status = "failed"
    end
end

def transcode? (source,dest,bitrate)
    #TODO here call ffmpeg to transcode
    IO.popen("ffmpeg -i #{source} -vcodec libx264 -acodec libfaac #{dest}}")
end

if __FILE__ == $0

    while true
        
       tasks = TranscodingTask.where(:status => 'new').order("priority").limit(5)
                    
       tasks.each do |task|
            run_task task
       end

       puts "idling"
       sleep 10
    end
end
