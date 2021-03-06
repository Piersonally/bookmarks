module ColumnsHelper
  
  def column_insert_button(column)
    link_to_remote('+', :url => insert_column_before_path(:id => column),
                        :method => :post,
                        :before => "$('spinner').show();",
                        :after  => "$('spinner').hide();")
  end
  
  def new_section_button(column)
    button_to_remote('New Section', :url => new_section_path(:column_id => column),
                                    :method => :post,
                                    :before => "$('spinner').show();",
                                    :after  => "$('spinner').hide();")
  end
  
  def add_column_on_right_button
    link_to_remote('+', :url => add_column_on_right_path,
                        :method => :post,
                        :before => "$('spinner').show();",
                        :after  => "$('spinner').hide();")
  end
 
  def column_delete_button(column)
    link_to_remote('&otimes;',
      :url => delete_column_path(:id => column),
      :method => :delete, 
      :confirm => "Are you sure you wish to delete this column?\n(this operation cannot be undone)",
      :before => "$('spinner').show();",
      :after  => "$('spinner').hide();")
  end
  
end
