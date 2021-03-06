require File.dirname(__FILE__) + '/../test_helper'

class SectionsControllerTest < ActionController::TestCase
  
  def setup
    @w = webpages(:page_1)
    @c = @w.columns.first
    @s = @c.sections.first
  end
  
  # Test REST CRUD scaffold actions
  
  # Index method is not implemented for sections.  Check this.
  def test_no_index_method
    assert_raise(ActionController::RoutingError) do
      get :index
    end
  end
  
  def test_routing
    object = @s
    path_prefix = "/admin/webpages/#{@w.id}/columns/#{@c.id}/sections"
    common_results =  { :controller => 'sections', :webpage_id => @w.id.to_s, :column_id => @c.id.to_s }
    assert_restful_routing(path_prefix, object, common_results, %w{ new create show edit update destroy })
  end
  
  def test_should_get_new
    get :new, :webpage_id => @w.id, :column_id => @c.id
    assert_response :success
    assert_select "#canvas form[action=/admin/webpages/#{@w.id}/columns/#{@c.id}/sections][method=post]"
  end

  def test_should_create_section
    assert_difference('Section.count') do
      post :create, :webpage_id => @w.id, :column_id => @c.id,
           :section => { :nth_section_from_top => 3, :title => "foo" }
    end
    assert_redirected_to webpage_column_path(@w, @c)
  end
  
  def test_should_show_section
    get :show, :webpage_id => @w.id, :column_id => @c.id, :id => @s.id
    assert_response :success
    assert_select 'div#canvas' do
      assert_select 'table#bookmarksTable' do
        # Check for known bookmarks
        @s.bookmarks.each do |bookmark|
          assert_select 'td.bookmarkNthFromTopOfSection', bookmark.nth_from_top_of_section.to_s
          assert_select 'td.bookmarkLegend', bookmark.legend
          assert_select 'td.bookmarkUrl', bookmark.url.to_s
          assert_select 'td.bookmarkImage', bookmark.image.to_s
          # Check for action links
          assert_select "td.rowAction a[href=#{edit_webpage_column_section_bookmark_path(@w,@c,@s,bookmark)}]", "Edit"
          assert_select "td.rowAction a[href=#{webpage_column_section_bookmark_path(@w,@c,@s,bookmark)}]", "Destroy"
        end
      end
    end
    assert_select "td#newBookmark a[href=#{new_webpage_column_section_bookmark_path(@w,@c,@s)}]"
  end
  
  def test_should_get_edit
    get :edit, :webpage_id => @w.id, :column_id => @c.id, :id => @s.id
    assert_response :success
    assert_select "#canvas form[action=#{webpage_column_section_path(@w,@c,@s)}][method=post]" do
      assert_select "input[type=hidden][name=_method][value=put]"
    end
  end

  def test_should_update_section
    put :update, :webpage_id => @w.id, :column_id => @c.id, :id => @s.id,
        :section => { :nth_section_from_top => 3, :title => "foo" }
    assert_redirected_to webpage_column_path(@w, @c)
  end

  def test_should_destroy_section
    assert_difference('Section.count', -1) do
      delete :destroy, :webpage_id => @w.id, :column_id => @c.id, :id => @s.id
    end
    assert_redirected_to webpage_column_path(@w, @c)
  end

  # Test Ajax actions
  
  def test_set_title
    section = sections(:page_1_col_1_sec_1)
    assert_routing({ :path => "/webpage_1/sections/#{section.id}/title", :method => :post },
                   { :controller => 'sections', :action => 'set_title', :site => 'webpage_1', :id => section.id.to_s } )
    newtitle = "ldjkfgeirutkdjflg"
    xhr :post, :set_title, :site => webpages(:page_1).url, :id => section.id, :value => newtitle
    assert_response :success
    section.reload
    assert_equal newtitle, section.title
    assert_match newtitle, @response.body
  end
  
  # Simulate drop of page_1_col_2_sec_1_mark_1 between page_1_col_1_sec_1_mark_1 and page_1_col_1_sec_1_mark_2
  def test_sort_bookmarks
    droptarget = sections(:page_1_col_1_sec_1)
    assert_routing({ :path => "/webpage_1/sections/#{droptarget.id}/sort", :method => :post },
                   { :controller => 'sections', :action => 'sort_bookmarks', :site => 'webpage_1', :id => droptarget.id.to_s } )
    dragged = bookmarks(:page_1_col_2_sec_1_mark_1)
    new_bookmark_order = [ bookmarks(:page_1_col_2_sec_1_mark_1).id, dragged.id, bookmarks(:page_1_col_1_sec_1_mark_2) ]
    assert_routing({ :path => "/webpage_1/sections/#{droptarget.id}/sort", :method => :post },
                   { :controller => 'sections', :action => 'sort_bookmarks', :site => 'webpage_1', :id => droptarget.id.to_s } )
    xhr :post, :sort_bookmarks, :site => webpages(:page_1).url, :id => droptarget.id.to_s,
        droptarget.droptarget_id => new_bookmark_order
    assert_response :success
    dragged.reload
    assert_equal droptarget, dragged.section
    assert_equal 2, dragged.nth_from_top_of_section
  end
  
  def test_new_section
    column = columns(:page_1_col_1)
    section_count_before = column.sections.size
    assert_routing({ :path => "/webpage_1/sections/#{column.id}/new", :method => :post },
                   { :controller => 'sections', :action => 'new_section', :site => 'webpage_1', :column_id => column.id.to_s } )
    xhr :post, :new_section, :site=> webpages(:page_1).url, :column_id => column.id.to_s
    assert_response :success
    assert assigns(:new_section)
    new_section = assigns(:new_section)
    assert_equal column, new_section.column
    assert_equal section_count_before+1, new_section.nth_section_from_top
    assert_equal section_count_before+1, column.sections.size
    assert_equal "New Section", new_section.title
    assert_select_rjs :insert_html, :bottom, column.droptarget_id, :partial => 'section', :object => @new_section
  end
  
end
