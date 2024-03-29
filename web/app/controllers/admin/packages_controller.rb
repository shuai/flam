require "video.rb"
require "admin_task.rb"

class Admin::PackagesController < ApplicationController
  #before_filter :authenticate_admin!
    
  # GET /packages
  # GET /packages.xml
  def index
    @packages = Package.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @packages }
    end
  end

  # GET /packages/1
  # GET /packages/1.xml
  def show
    @package = Package.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @package }
    end
  end

  # GET /packages/new
  # GET /packages/new.xml
  def new
    @package = Package.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @package }
    end
  end

  # GET /packages/1/edit
  def edit
    @package = Package.find(params[:id])
  end

  # POST /packages
  # POST /packages.xml
  def create
    @package = Package.new
    @task = PackageTask.new(:status => "new")  
        
    respond_to do |format|
      if (File.directory?(params[:location]) or Video.is_video?(params[:location])) and @task.save
        format.html { redirect_to(admin_root_path, :notice => 'Package was successfully created.') }
        format.xml  { render :xml => @package, :status => :created, :location => @package }
      else
        if @package.errors.size == 0
            @package.errors["Error"] = "The path is not a directory or video file."
        end
        format.html { render :action => "new" }
        format.xml  { render :xml => @package.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /packages/1
  # PUT /packages/1.xml
  def update
    @package = Package.find(params[:id])

    respond_to do |format|
      if @package.update_attributes(params[:package])
        format.html { redirect_to([:admin,@package], :notice => 'Package was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @package.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /packages/1
  # DELETE /packages/1.xml
  def destroy
    @package = Package.find(params[:id])
    @package.destroy

    respond_to do |format|
      format.html { redirect_to(admin_packages_url) }
      format.xml  { head :ok }
    end
  end
end
