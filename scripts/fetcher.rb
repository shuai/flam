#! /usr/bin/env ruby

#处理下载回来的资源包，解压，生成唯一ID，找出视频和字幕文件写入数据库

require 'rubygems'
require 'fileutils'
require 'tmpdir'
require 'uuid'
require 'ftools'
require "mysql"

require "common.rb"

def is_video(name)

    Video_extension.each do |ext|
        if name.length >= ext.length + 1 
            if name[name.length-ext.length,ext.length] == ext
                return true
            end
        end
    end
    
    false        
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
def save_resources(videos, captions, package_id)
    if videos.size + captions.size > 0
       puts "Found #{videos.size} videos and #{captions.size} captions"
    else
       return
    end

    my = Mysql::new(Sql_host, Sql_user, Sql_pswd, Sql_database)
    
    puts "wtf"
    videos.each do |v|
        sql_query = "insert into #{Sql_tbl_raw_resource}(title,location,package) VALUES('#{v}','#{v}','#{package_id}');"
        res = my.query(sql_query)
    end
    
    captions.each do |v|
        res = my.query("insert into #{Sql_tbl_captions}(location,package) VALUES('#{v}',#{package_id});")
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
    my = Mysql::new(Sql_host, Sql_user, Sql_pswd, Sql_database)
    
    while true
        res = my.query("select * from #{Sql_tbl_package} where status = 'new'")
        
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
        
        puts 'idling'
        sleep 100
    end
end

