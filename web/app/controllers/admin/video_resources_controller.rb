class Admin::VideoResourcesController < ApplicationController
  # GET /video_resources
  # GET /video_resources.xml
  def index
    @video_resources = VideoResource.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @video_resources }
    end
  end

  # GET /video_resources/1
  # GET /video_resources/1.xml
  def show
    @video_resource = VideoResource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @video_resource }
    end
  end

  # GET /video_resources/new
  # GET /video_resources/new.xml
  def new
    @video_resource = VideoResource.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @video_resource }
    end
  end

  # GET /video_resources/1/edit
  def edit
    @video_resource = VideoResource.find(params[:id])
  end

  # POST /video_resources
  # POST /video_resources.xml
  def create
    @video_resource = VideoResource.new(params[:video_resource])

    respond_to do |format|
      if @video_resource.save
        format.html { redirect_to(@video_resource, :notice => 'Video resource was successfully created.') }
        format.xml  { render :xml => @video_resource, :status => :created, :location => @video_resource }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @video_resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /video_resources/1
  # PUT /video_resources/1.xml
  def update
    @video_resource = VideoResource.find(params[:id])

    respond_to do |format|
      if @video_resource.update_attributes(params[:video_resource])
        format.html { redirect_to(@video_resource, :notice => 'Video resource was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @video_resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /video_resources/1
  # DELETE /video_resources/1.xml
  def destroy
    @video_resource = VideoResource.find(params[:id])
    @video_resource.destroy

    respond_to do |format|
      format.html { redirect_to(video_resources_url) }
      format.xml  { head :ok }
    end
  end
end
