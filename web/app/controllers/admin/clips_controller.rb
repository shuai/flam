class Admin::ClipsController < ApplicationController
    def show
        @clip = Clip.find(params[:id])
    end
    
    def stream
        @clip = Clip.find(params[:id])
        
        if !@clip.nil?
            send_file @clip.location, :type => "video/x-f4v"
            return
        else
            render :text => "404 Not Found", :status => 404
        end
    end
end
