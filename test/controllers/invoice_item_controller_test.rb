require 'test_helper'

class InvoiceItemControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
