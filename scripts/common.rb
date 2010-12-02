########################################################
# params

Db_config = "/home/shuai/work/flam/web/config/database.yml"
Db_environment = "development"


#目标文件夹结构     
Incoming = "/tmp/download/complete/"
Raw_files_dir = "/srv/data/raw/"
Clip_dir='/srv/data/clips/'


#TODO 完全列表
Caption_extension = ['.wtf']
########################################################

def getcliplocation(raw_video_id, bitrate)
    "#{Clip_dir}#{raw_video_id}/#{bitrate}.mp4"
end
    
    
