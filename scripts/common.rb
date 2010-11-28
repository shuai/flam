########################################################
# params

Db_config = "/home/shuai/work/flam/web/config/database.yml"
Db_environment = "development"

Sql_host = "localhost"
Sql_user = "root"
Sql_pswd = "sqlroot"
Sql_database = "db_flam"
Sql_tbl_raw_resource = "raw_videos"
Sql_tbl_raw_video_stream = "raw_video_streams"
Sql_tbl_captions="captions"
Sql_tbl_package="packages"
Sql_tbl_clip="clips"
Sql_tbl_task="admin_tasks"

# table fields
Rawvideo_location = "location"

Clip_location = "location"
Clip_bitrate = "bitrate"
Clip_rawvideo = "raw_video_id"

#目标文件夹结构
#视频唯一编号/视频资源目录/原始资源包(包括目录)        
Raw_files_dir='/home/shuai/work/rawvideos/'
Clip_dir='/home/shuai/work/clips/'
Source_dir = ''

#TODO 完全列表
Caption_extension = ['.wtf']
########################################################

def getcliplocation(raw_video_id, bitrate)
    "#{Clip_dir}#{raw_video_id}/#{bitrate}.mp4"
end
    
    
