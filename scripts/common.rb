########################################################
# params

Db_config = "../web/config/database.yml"
Db_environment = "production"


#目标文件夹结构     
Incoming = "/srv/download/complete/"
Raw_files_dir = "/srv/data/raw/"
Clip_dir='/srv/data/clips/'

Utorrent_srv="localhost"
Utorrent_port = 8080
Utorrent_user = "admin"
Utorrent_psw = ""

#TODO 完全列表
Caption_extension = ['.wtf']
########################################################

def getcliplocation(raw_video_id, bitrate)
    "#{Clip_dir}#{raw_video_id}/#{bitrate}.mp4"
end
    
def dbg(s)
    if ARGV.include? "-verbose"
        puts s
    end
end
