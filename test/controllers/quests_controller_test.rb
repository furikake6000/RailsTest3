require 'test_helper'

class QuestsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get quests_new_url
    assert_response :success
  end

  test "should get show" do
    get quests_show_url
    assert_response :success
  end

  test "should get destroy" do
    get quests_destroy_url
    assert_response :success
  end

end
