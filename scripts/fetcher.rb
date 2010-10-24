#! /usr/bin/env ruby

#处理下载回来的资源包，解压，生成唯一ID，找出视频和字幕文件写入数据库

########################################################
# params

sql_host = "localhost"
sql_user = "root"
sql_pswd = "idontknow"
sql_database = "db_flam"
sql_tbl_raw_resource = "raw_videos"
sql_tbl_captions="captions"
sql_tbl_package="packages"

#目标文件夹结构
#视频唯一编号/视频资源目录/原始资源包(包括目录)        
raw_files_dir=''
source_dir = ''

#TODO 完全列表
video_extension = ['.rmvb','.rm','.mkv','.avi','.wmv','.flv','.f4v','.mov']
caption_extension = ['.wtf']
########################################################

require 'rubygems'
require 'fileutils'
require 'tmpdir'
require 'uuid'
require 'ftools'
require "mysql"

def is_video(name)
    video_extension.each do |ext|
        if name.length > ext.length + 1 and name[name.length-ext.length,ext.length] == ext
            return true
        end
    end
    
    false        
end

def is_caption(name)
    caption_extension.each do |ext|
        if name.length > ext.length + 1 and name[name.length-ext.length,ext.length] == ext
            return true
        end
    end
    
    false      
end

#视频文件写到raw_video数据库
def save_resources(videos, captions, package_id)
    my = Mysql::new(sql_host, sql_user, sql_pswd, sql_database)
    
    videos.each do |v|
        res = my.query("insert into #{sql_tbl_raw_resource}(title,location,package) 
                        VALUES(#{v},#{v},#{package_id});")
    end
    
    captions.each do |v|
        res = my.query("insert into #{sql_tbl_captions}(location,package) 
                        VALUES(#{v},#{package_id});")
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
            
        file = File.new filename
        if file.directory? 
            search_dirctory(directory)
        elsif is_video filename
            @videos << filename
            puts "Video file #{filename}"
        elsif is_caption filename
            @captions << filename
            puts "Caption file #{filename}"
        else
            puts "Unrecognized file #{filename}"
        end
    end
end

def parse_resource(url)
    if !url.nil? && !url.empty?
        dirname = url.split('/').last
        uuid = UUID.new
        if url[url.length-1] == '/'
            FileUtils.mv url, "#{raw_files_dir}/#{uuid}/#{dirname}"
            handle_directory "#{raw_files_dir}/#{uuid}/#{dirname}", uuid
        else
            raise 'Handle zipped package!'
            # TODO 处理压缩包
        end
    end 
end

if __FILE__ == $0
    my = Mysql::new(sql_host, sql_user, sql_pswd, sql_database)
    
    while true
        res = my.query("select * from #{sql_tbl_package} where status = 'new'")
        
        res.each do |row|
          loc = row[:location]
          puts "New task #{loc} ..."
          begin 
            parse_resource(loc)
          rescue
            puts "task failed"
          end
        end
        
        puts 'idling'
        sleep 5
    end
end

