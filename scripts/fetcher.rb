#! /usr/bin/env ruby

#处理下载回来的资源包，解压，生成唯一ID，找出视频和字幕文件写入数据库

require 'rubygems'
require 'fileutils'
require 'tmpdir'
require 'uuid'
require 'ftools'
require "mysql"

require "common.rb"
require "video.rb"
require "models.rb"

def is_video(name)
    Video.is_video? name      
end

def is_caption(name)
    Caption_extension.each do |ext|
        if name.length > ext.length + 1 and name[name.length-ext.length,ext.length] == ext
            return true
        end
    end
    
    false      
end

#视频文件写到raw_video数据库
def save_video(path, package_id)

    v = Video.new path
    if v.is_video?
        new_video = RawVideo.new(:location => path, :package => package_id, :title => v.Title, :format => v.Format, :duration => v.Duration,
                                :size => v.Size, :author => v.Author, :copyright => v.Copyright, :comment => v.Comment)
        

        
        v.Streams.each do |s|
            new_video.raw_video_streams.create(:index => s.Index, :codec => s.Codec, :codec_long => s.CodecLong, :type => s.Type, 
                                               :sample_rate => s.SampleRate, :channels => s.Channels, :bits_per_sample => s.BitPerSample,
                                               :avg_framerate => s.AvgFramerate, :start_time => s.StartTime, :duration => s.Duration)
        end
        
        if !new_video.save
            puts "Failed to write video record"
        end
    else
        puts "Not a video #{path}"
    end
end

def save_resources(videos, captions, package_id)
    if videos.size + captions.size > 0
       puts "Found #{videos.size} videos and #{captions.size} captions"
    else
       return
    end
    
    videos.each do |v|
        save_video(v,package_id)
    end
    
    captions.each do |v|
        Captions.new(:location => v, :package => package_id).save
    end
        
end

# 搜索目录，寻找视频文件和字幕,添加到数据库
# directory: target目录
# package_id： package的uuid
def handle_directory(directory,package_id)
    @videos=[]
    @captions=[]
    
    search_dirctory(directory)
    save_resources(@videos, @captions, package_id)
end


def search_dirctory(directory)
    Dir.foreach(directory) do |filename|
        if filename == '.' or filename == '..'
            next
        end
            
        full_path = directory + filename
        if File.directory? full_path 
            search_dirctory(directory)
        elsif is_video filename
            @videos << full_path
            puts "Video file #{filename}"
        elsif is_caption filename
            @captions << fullpath
            puts "Caption file #{filename}"
        else
            puts "Unrecognized file #{filename}"
        end
    end
end

def parse_resource(dir)
    if !dir.nil? && !dir.empty?
        dirname = dir.split('/').last
        uuid = UUID.generate
          
        if File.directory? dir or File.file? dir and is_video dir
            system "mkdir #{Raw_files_dir}#{uuid}/"
	        system "mv #{dir} #{Raw_files_dir}#{uuid}/"
            handle_directory "#{Raw_files_dir}#{uuid}/", uuid    
	else
            raise  "'#{dir}' is not a valid path"
            # TODO 处理压缩包
        end
    end 
end

if __FILE__ == $0
    
    while true
        tasks = PackageTask.where(:status => 'new').order("priority").limit(5)
        
        tasks.each do |task|
          puts "================================================="
          puts "Walk through package '#{task.location}' ..."
          begin 
            parse_resource(task.location)
          rescue => e
            puts "task failed", e
          end
        end
        
        puts 'idling ...'
        sleep 100
    end
end

