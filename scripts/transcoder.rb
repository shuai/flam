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
        clip = Video.new dest
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
    if File.exist? dest
        puts "#{dest} already exists, wtf is wrong?"
        return false
    end
    
    IO.popen("ffmpeg -i #{source} -pass 1 -vcodec libx264 -vpre slow_firstpass -b #{bitrate} -bt #{bitrate * 2} #{dest}")
    if !Video.new(dest).is_video?
        puts "Transcoding failed"
        return false
    end
    
    IO.popen("rm #{dest}")
    if File.exist? dest
        puts "Failed to remove temporary output"
        return false
    end
    
    IO.popen("ffmpeg -i #{source} -acodec libfaac -ab 32k -pass 2 -vcodec libx264 -vpre slow -b #{bitrate} -bt #{bitrate*2}  #{dest}")
    if !Video.new(dest).is_video?
        return true
    else
        return false
    end
    
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
