require 'test_helper'

class RawVideosControllerTest < ActionController::TestCase
  setup do
    @raw_video = raw_videos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:raw_videos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create raw_video" do
    assert_difference('RawVideo.count') do
      post :create, :raw_video => @raw_video.attributes
    end

    assert_redirected_to raw_video_path(assigns(:raw_video))
  end

  test "should show raw_video" do
    get :show, :id => @raw_video.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @raw_video.to_param
    assert_response :success
  end

  test "should update raw_video" do
    put :update, :id => @raw_video.to_param, :raw_video => @raw_video.attributes
    assert_redirected_to raw_video_path(assigns(:raw_video))
  end

  test "should destroy raw_video" do
    assert_difference('RawVideo.count', -1) do
      delete :destroy, :id => @raw_video.to_param
    end

    assert_redirected_to raw_videos_path
  end
end
