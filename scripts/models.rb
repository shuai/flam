require "common.rb"
require "rubygems"
require "active_record"
require 'active_support/all'
require "yaml"

model_dir = "../web/app/models/"
require model_dir + "admin_task.rb"
require model_dir + "package.rb"
require model_dir + "raw_video.rb"
require model_dir + "raw_video_stream.rb"
require model_dir + "caption.rb"
require model_dir + "clip.rb"

dbconfig = YAML::load(File.open(Db_config))
ActiveRecord::Base.establish_connection(dbconfig[Db_environment])   

