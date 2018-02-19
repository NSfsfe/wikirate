include_set Abstract::Header
include_set Abstract::Tabs
include_set Abstract::Media

format :html do
  view :open_content do |args|
    two_column_layout
  end

  def two_column_layout col1=6, col2=6, row_hash={}
    row_hash[:class] ||= "panel-margin-fix"
    bs_layout container: false, fluid: true, class: @container_class do
      row col1, col2, row_hash do
        column _render_content_left_col, left_column_class
        column _render_content_right_col, right_column_class
      end
    end
  end

  def left_column_class
    "left-col"
  end

  def right_column_class
    "right-col"
  end

  view :rich_header do |_args|
    bs_layout do
      row 12 do
        col class: "nopadding rich-header" do
          text_with_image title: "", text: header_right, size: :large
        end
      end
    end
  end

  def header_image
    wrap_with :div, class: "image-box large-rect" do
      field_nest(:image, size: :large)
    end
  end

  def header_right
    wrap_with :h3, _render_title, class: "header-right"
  end

  view :content_right_col do
    _render_tabs
  end

  view :content_left_col do
    # had slot before
    output [_render_rich_header, _render_data]
  end

  view :data, cache: :never do
    wrap do
      [_render_filter, _render_table]
    end
  end
end
