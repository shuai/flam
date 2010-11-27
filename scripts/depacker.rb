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
def save_video(path, package)
    v = Video.new path
    if v.is_video?
        new_video = RawVideo.new(:location => path, :package => package, :title => v.Title, :format => v.Format, :duration => v.Duration,
                                :bitrate => v.Bitrate, :size => v.Size, :author => v.Author, :copyright => v.Copyright, :comment => v.Comment)
        
        if !new_video.save
            raise "Failed to write video record"
        end

        v.Streams.each do |s|
            new_video.raw_video_streams.create(:index => s.Index, :codec => s.Codec, :codec_long => s.CodecLong, :type => s.Type, 
                                               :sample_rate => s.SampleRate, :channels => s.Channel, :bits_per_sample => s.BitPerSample,
                                               :avg_framerate => s.AvgFrameRate, :start_time => s.StartTime, :duration => s.Duration)
        end

    else
        raise "Not a video #{path}"
    end
end

def save_resources(videos, captions, package_path, package_id)
    puts "Creating package: #{package_id}"
    
    new_pack = Package.new(:id => package_id, :location => package_path)
    if !new_pack.save
       raise "Error occured when writing package to database"
    end
    
    begin 
        videos.each do |v|
            save_video(v, new_pack)
        end
        
        captions.each do |v|
            Captions.new(:location => v, :package => new_pack).save
        end
    rescue => e
        new_pack.destroy
        raise e
    end
end

# 搜索目录，寻找视频文件和字幕,添加到数据库
# directory: target目录
# package_id： package的uuid
def handle_directory(directory,package_id)
    @videos=[]
    @captions=[]
    
    search_dirctory(directory)
    
    if @videos.size == 0 and @captions.size == 0
        $error = "Failed to find valid video file"
        return
    end
    
    save_resources(@videos, @captions, directory, package_id)
end


def search_dirctory(directory)
    Dir.foreach(directory) do |filename|
        if filename == '.' or filename == '..'
            next
        end
        
        full_path = File.join directory,filename
          
        if File.directory? full_path
            search_dirctory(full_path)
        elsif is_video full_path
            @videos << full_path
        elsif is_caption full_path
            @captions << fullpath
        end
    end
end

def parse_resource(dir)
    if !dir.nil? && !dir.empty?
        dirname = dir.split('/').last
        uuid = UUID.generate
          
        if File.directory? dir or (File.file? dir and is_video dir)
            system "mkdir #{Raw_files_dir}#{uuid}/"
	        system "mv #{dir} #{Raw_files_dir}#{uuid}/"
            handle_directory "#{Raw_files_dir}#{uuid}/", uuid    
	    else
            $error = "Not a valid directory or video file"
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
          
          $error = nil
          
          begin
            task.status = "ing"
            task.save
            parse_resource(task.location)
          rescue => e
            $error = e.to_str
          end
          
          puts $error
          if !$error.nil?
            task.status = "failed"
            task.err_msg = $error
            task.save
          else
            task.status = "done"
            task.err_msg = ""
            task.save
          end
          
        end
        
        puts 'idling ...'
        sleep 5
    end
end

