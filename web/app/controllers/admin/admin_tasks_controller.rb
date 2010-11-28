require "video.rb"

class Admin::AdminTasksController < ApplicationController
    def new
        if params[:type] == "transcoding"
            @task = TranscodingTask.new(:status => "new")
            @video = RawVideo.find(params[:raw_video_id])
        elsif params[:type] == "package"
            @task = PackageTask.new(:status => "new")
        end 
    end
    
    def create
        if params[:type] == "transcoding"
            @task = TranscodingTask.new(:status => "new", :raw_video_id => params["raw_video_id"], :bitrate => params["bitrate"].to_i*1024)
        elsif params[:type] == "package"
            @task = PackageTask.new(:status => "new", :location => params["location"])
        else
            @task = AdminTask.new
        end
        
        if @task.type.nil?
            @task.errors["Error"] = "Wrong parameter(type)."
            render :action => "new"
            return
        end
        
        if @task.type == "TranscodingTask"
            video = RawVideo.find(params["raw_video_id"])
            
            if video.nil?
                @task.errors["Error:"] = "Video doesn't exist"
            elsif video.bitrate <= 0
                @task.errors["Error:"] = "Invalid target bitrate"
            elsif video.bitrate < params["bitrate"].to_i
                @task.errors["Error:"] = "Target bitrate shouldn't be larger than the raw video(#{video.bitrate})"
            elsif @task.save
                redirect_to(admin_root_path, :notice => 'Transcoding request was successfully created.')
                return
            end
        elsif @task.type == "PackageTask"
            if (File.directory?(params[:location]) or Video.is_video?(params[:location])) and @task.save
                redirect_to(admin_root_path, :notice => 'Package was successfully created.')
                return
            else
               @task.errors["Error:"] = "Path has to be a directory or a video file"
            end
        end
        
        render :action => "new"
        return
    end
    
    def destroy
        @task = AdminTask.find(params[:id])
        @task.destroy

        respond_to do |format|
          format.html { redirect_to(admin_root_path) }
        end
    end
end
