class Admin::AdminsController < ApplicationController
    #before_filter :authenticate_admin!
    
    def index
        @packages = Package.all
    end
    
    def create
        
    end
end
