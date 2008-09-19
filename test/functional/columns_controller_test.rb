require File.dirname(__FILE__) + '/../test_helper'

class ColumnsControllerTest < ActionController::TestCase

  # Index method is not implemented for columns.
  # SAM how to check this?
  
  def setup
    @w = webpages(:page_1)
    @c = @w.columns.first
  end
  
  def test_routing
    object = @c
    path_prefix = "/admin/webpages/#{@w.id}/columns"
    common_results =  { :controller => 'columns', :webpage_id => @w.id.to_s }
    assert_restful_routing(path_prefix, object, common_results, %w{ new create show edit update destroy })
  end
  
  def test_should_get_new
    get :new, :webpage_id => @w.id
    assert_response :success
    assert_select "#canvas form[action=/admin/webpages/#{@w.id}/columns][method=post]"
  end

  def test_should_create_column
    w = webpages(:page_1)
    assert_difference('Column.count') do
      post :create, :webpage_id => @w.id, :column => { :nth_from_left => 3 }
    end
    assert_redirected_to webpage_path(@w)
  end
  
  def test_should_show_column
    get :show, :webpage_id => @w.id, :id => @c.id
    assert_response :success
    assert_select 'div#canvas' do
      assert_select 'table#sectionsTable' do
        # Check for known sections
        @c.sections.each do |section|
          assert_select 'td.sectionNthSectionFromTop', "#{section.nth_section_from_top}"
          assert_select 'td.sectionTitle', "#{section.title}"
          # Check for action links
          assert_select "td.rowAction a[href=#{webpage_column_section_path(@w,@c,section)}]", "Show"
          assert_select "td.rowAction a[href=#{edit_webpage_column_section_path(@w,@c,section)}]", "Edit"
          assert_select "td.rowAction a[href=#{webpage_column_section_path(@w,@c,section)}]", "Destroy"
        end
      end
    end
    assert_select "td#newSection a[href=#{new_webpage_column_section_path(@w,@c)}]"
  end
  
  def test_should_get_edit
    get :edit, :webpage_id => @w.id, :id => @c.id
    assert_response :success
    assert_select "#canvas form[action=#{webpage_column_path(@w,@c)}][method=post]" do
      assert_select "input[type=hidden][name=_method][value=put]"
    end
  end

  def test_should_update_column
    put :update, :webpage_id => @w.id, :id => @c.id, :column => { :nth_from_left => 3 }
    assert_redirected_to webpage_path(@w)
  end

  def test_should_destroy_column
    assert_difference('Column.count', -1) do
      delete :destroy, :webpage_id => @w.id, :id => @c.id
    end
    assert_redirected_to webpage_path(@w)
  end

end
