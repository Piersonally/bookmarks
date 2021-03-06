require File.dirname(__FILE__) + '/../test_helper'

class BookmarksControllerTest < ActionController::TestCase
  # Index method is not implemented for bookmarks.
  # Show method is not implemented for bookmarks.
  # SAM how to check this?
  
  def setup
    @w = webpages(:page_1)
    @c = @w.columns.first
    @s = @c.sections.first
    @b = @s.bookmarks.first
  end
  
  def test_routing
    object = @b
    path_prefix = "/admin/webpages/#{@w.id}/columns/#{@c.id}/sections/#{@s.id}/bookmarks"
    common_results =  { :controller => 'bookmarks', :webpage_id => @w.id.to_s,
                        :column_id => @c.id.to_s, :section_id => @s.id.to_s }
    assert_restful_routing(path_prefix, object, common_results, %w{ new create edit update destroy })
  end
  
  def test_should_get_new
    get :new, :webpage_id => @w.id, :column_id => @c.id, :section_id => @s.id
    assert_response :success
    assert_select "#canvas form[action=/admin/webpages/#{@w.id}/columns/#{@c.id}/sections/#{@s.id}/bookmarks][method=post]"
  end

  def test_should_create_section
    assert_difference('Bookmark.count') do
      post :create, :webpage_id => @w.id, :column_id => @c.id, :section_id => @s.id,
           :bookmark => { :nth_from_top_of_section => 3, :legend => "foo" }
    end
    assert_redirected_to webpage_column_section_path(@w, @c, @s)
  end

  def test_should_get_edit
    get :edit, :webpage_id => @w.id, :column_id => @c.id, :section_id => @s.id, :id => @b.id
    assert_response :success
    assert_select "#canvas form[action=#{webpage_column_section_bookmark_path(@w,@c,@s,@b)}][method=post]" do
      assert_select "input[type=hidden][name=_method][value=put]"
    end
  end

  def test_should_update_section
    put :update, :webpage_id => @w.id, :column_id => @c.id, :section_id => @s.id, :id => @b.id,
        :bookmark => { :nth_from_top_of_section => 3, :legend => "foo" }
    assert_redirected_to webpage_column_section_path(@w, @c, @s)
  end

  def test_should_destroy_section
    assert_difference('Bookmark.count', -1) do
      delete :destroy, :webpage_id => @w.id, :column_id => @c.id, :section_id => @s.id, :id => @b.id
    end
    assert_redirected_to webpage_column_section_path(@w, @c, @s)
  end

  # Test Ajax actions
  
  def test_new_bookmark
    bookmark_count_before = @s.bookmarks.size
    assert_routing({ :path => "/webpage_1/bookmarks/#{@s.id}/new", :method => :post },
                   { :controller => 'bookmarks', :action => 'new_bookmark', :site => 'webpage_1', :section_id => @s.id.to_s } )
    xhr :post, :new_bookmark, :site => @w.url, :section_id => @s.id
    assert_response :success
    assert assigns(:new_bookmark)
    new_bookmark = assigns(:new_bookmark)
    assert_equal @s, new_bookmark.section
    assert_equal bookmark_count_before+1, new_bookmark.nth_from_top_of_section
    assert_equal bookmark_count_before+1, @s.bookmarks.size
    assert_equal "New Bookmark", new_bookmark.legend
    assert_select_rjs :insert_html, :bottom, @s.droptarget_id, :partial => 'li_bookmark', :object => new_bookmark 
  end
  
  def test_edit_bookmark
    assert_routing({ :path => "/webpage_1/bookmarks/#{@b.id}/edit", :method => :post },
                   { :controller => 'bookmarks', :action => 'edit_bookmark', :site => 'webpage_1', :id => @b.id.to_s } )
    xhr :post, :edit_bookmark, :site => 'webpage_1', :id => @b.id
    assert_response :success
    assert assigns(:bookmark)
    assert_select_rjs :insert_html, :top, 'body'
    assert_select_rjs :insert_html, :top, 'lane', :partial => 'edit_bookmark', :locals => { :style => 'display: none;' }    
  end
  
  def test_update_bookmark
    assert_routing({ :path => "/webpage_1/bookmarks/#{@b.id}/update", :method => :post },
                   { :controller => 'bookmarks', :action => 'update_bookmark', :site => 'webpage_1', :id => @b.id.to_s } )
    xhr :post, :update_bookmark, :site => 'webpage_1', :id => @b.id
    assert_response :success
    assert assigns(:bookmark)
    assert_select_rjs :replace_html, @b.draggable_id, :partial => 'bookmark', :object => @b
  end
  
  def test_set_legend
    assert_routing({ :path => "/webpage_1/bookmarks/#{@b.id}/legend", :method => :post },
                   { :controller => 'bookmarks', :action => 'set_legend', :site => 'webpage_1', :id => @b.id.to_s } )
    new_legend = random_string(16)
    xhr :post, :set_legend, :site => 'webpage_1', :id => @b.id, :value => new_legend
    assert_response :success
    @b.reload
    assert_equal new_legend, @b.legend
  end

  def test_set_url
    assert_routing({ :path => "/webpage_1/bookmarks/#{@b.id}/url", :method => :post },
                   { :controller => 'bookmarks', :action => 'set_url', :site => 'webpage_1', :id => @b.id.to_s } )
    new_url = random_string(16)
    xhr :post, :set_url, :site => 'webpage_1', :id => @b.id, :value => new_url
    assert_response :success
    @b.reload
    assert_equal new_url, @b.url
  end
  
end
