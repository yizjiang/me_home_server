require 'test_helper'

class PostCardsControllerTest < ActionController::TestCase
  setup do
    @post_card = post_cards(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:post_cards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create post_card" do
    assert_difference('PostCard.count') do
      post :create, post_card: { content: @post_card.content, user_id: @post_card.user_id }
    end

    assert_redirected_to post_card_path(assigns(:post_card))
  end

  test "should show post_card" do
    get :show, id: @post_card
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @post_card
    assert_response :success
  end

  test "should update post_card" do
    put :update, id: @post_card, post_card: { content: @post_card.content, user_id: @post_card.user_id }
    assert_redirected_to post_card_path(assigns(:post_card))
  end

  test "should destroy post_card" do
    assert_difference('PostCard.count', -1) do
      delete :destroy, id: @post_card
    end

    assert_redirected_to post_cards_path
  end
end
