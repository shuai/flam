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
        sql_query = "insert into #{Sql_tbl_raw_resource}(location,package,bitrate,title,format,duration,size,author,copyright,comment)"
                    "VALUES('#{path}','#{package_id}',#{v.Bitrate},'#{v.Title}','#{v.Format}',#{v.Duration},#{v.Size},'#{v.Author}','#{v.Copyright}','#{v.Comment}');"
        res = $my.query(sql_query)
        
        v.Streams.each do |s|
            sql_query = "insert into #{Sql_tbl_raw_video_stream}(raw_video_id,index,codec,codec_long,type,sample_rate,channels,bits_per_sample,avg_framerate,start_time,duration)"
                        "values(#{res.insert_id}, #{s.Index}, '#{s.Codec}','#{s.CodecLong}', '#{s.Type}', #{s.SampleRate}, #{s.Channels}, #{s.BitPerSample}, #{s.AvgFramerate}, #{s.StartTime}, #{s.Duration})"
            $my.query(sql_query) 
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
        res = $my.query("insert into #{Sql_tbl_captions}(location,package) VALUES('#{v}',#{package_id});")
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
        $my = Mysql::new(Sql_host, Sql_user, Sql_pswd, Sql_database)
        res = $my.query("select * from #{Sql_tbl_package} where status = 'new'")
        
        res.each do |row|
          loc = row[1] #location
          puts "================================================="
          puts "New task '#{loc}' ..."
          begin 
            parse_resource(loc)
          rescue => e
            puts "task failed", e
          end
        end
        
        $my = nil
        
        puts 'idling ...'
        sleep 100
    end
end

