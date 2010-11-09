require 'test_helper'

class VideoResourcesControllerTest < ActionController::TestCase
  setup do
    @video_resource = video_resources(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:video_resources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create video_resource" do
    assert_difference('VideoResource.count') do
      post :create, :video_resource => @video_resource.attributes
    end

    assert_redirected_to video_resource_path(assigns(:video_resource))
  end

  test "should show video_resource" do
    get :show, :id => @video_resource.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @video_resource.to_param
    assert_response :success
  end

  test "should update video_resource" do
    put :update, :id => @video_resource.to_param, :video_resource => @video_resource.attributes
    assert_redirected_to video_resource_path(assigns(:video_resource))
  end

  test "should destroy video_resource" do
    assert_difference('VideoResource.count', -1) do
      delete :destroy, :id => @video_resource.to_param
    end

    assert_redirected_to video_resources_path
  end
end
