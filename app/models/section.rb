class Section < ActiveRecord::Base
  belongs_to :column
  has_many :bookmarks, :order => :nth_from_top_of_section, :dependent => :delete_all
  validates_numericality_of :nth_section_from_top, :only_integer => true
  validate :column_must_exist

  # A user-friendly name for this section that can be used in links.
  def full_name
    "#{column.webpage.url} column #{column.nth_from_left} section #{nth_section_from_top}:#{title}"
  end  

  # Generates a DOM ID we can use to manipulate this entity when it is in the HTML page.
  def dom_id
    "section_#{id}"
  end
  
  def draggable_id
    "draggableSection_#{id}"
  end
  
  def droptarget_id
    "droptargetSection_#{id}"
  end
  
  private
  
  def column_must_exist
    errors.add(:column_id, "must refer to an existing column") if column.nil?
  end
  
end
