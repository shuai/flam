#! /usr/bin/env ruby

# Transcode raw videos to bitrates we want

require "common.rb"
require "mysql"
require "models.rb"
require "video.rb"

def run_task(task)
    puts "==========================="
    puts "transcoding '#{task.raw_video_id}' target bitrates #{task.bitrate}"
    
    if task.raw_video.nil?
        task.status = "failed"
        task.err_msg = "invalid raw video"
        task.save
        puts "failed"
        return
    end
    
    task.status = "ing"
    task.save
    
    source = task.raw_video.location
    dest = getcliplocation(task.raw_video_id, task.bitrate)
    
    error = ""
    begin
        transcode(source, dest, task.bitrate)
        
        clip = Video.new(dest)
        if clip.is_video?
            record = Clip.new(:raw_video_id => task.raw_video_id, :location => dest, :bitrate => clip.Bitrate, :duration => clip.Duration)
            if record.save
                task.status = "done"
            else
                error = "failed to write clip to database"
            end
        else
            error = "invalid output"
        end
    rescue => e
       error = e.to_str
    end
    
    if task.status == "ing"
        task.status = "failed"
        task.err_msg = error
    end
    
    task.save
end

def transcode (source,dest,bitrate)
    #TODO here call ffmpeg to transcode
    if File.exist? dest
        raise "#{dest} already exists, wtf is wrong?"
    end
    
    if !File.directory? File.dirname(dest)
        Dir.mkdir(File.dirname(dest))
    end

    IO.popen("ffmpeg -i \"#{source}\" -pass 1 -vcodec libx264 -vpre slow_firstpass -b #{bitrate} -bt #{bitrate * 2} #{dest}").eof?
    if !Video.new(dest).is_video?
        raise "ffmpege failed"
    end

    IO.popen("rm #{dest}").eof?
    if File.exist? dest
        raise "Failed to remove temporary output"
    end
    
    IO.popen("ffmpeg -i \"#{source}\" -acodec libfaac -ab 32k -pass 2 -vcodec libx264 -vpre slow -b #{bitrate} -bt #{bitrate*2}  #{dest}").eof?
end

if __FILE__ == $0

    while true
        
       tasks = TranscodingTask.where(:status => 'new').order("priority").limit(5)
                   
       tasks.each do |task|
            run_task task
       end

       puts "idling"
       sleep 5
    end
end
