require "admin_task.rb"

class Admin::AdminsController < ApplicationController
    #before_filter :authenticate_admin!
    
    def index
        #ongoing package task
        
        @package_ing = PackageTask.where(:status => 'ing')
        @package_tasks = PackageTask.where(:status => 'new')
        
        @package_failed_tasks = PackageTask.where(:status => 'failed')
                
        #ongoing transcoding task
        @packages = Package.all
    end
    
    def create
        
    end
end
