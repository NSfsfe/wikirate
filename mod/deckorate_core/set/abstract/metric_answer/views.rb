include_set Abstract::DeckorateTabbed

format do
  delegate :metric_designer_card, to: :metric_card

  view :legend, unknown: true do
    nest card.metric_card, view: :legend
  end
end

format :html do
  def header_title
    haml :header_title
  end

  def header_text
    haml :header_text
  end

  bar_cols 8, 1, 3

  view :bar_right, unknown: true do
    handle_unknowns { haml :bar_right }
  end

  view :year_and_value_pretty, unknown: true, template: :haml

  view :bar_middle do
    render_markers
  end

  view :metric_thumbnail, unknown: true do
    nest card.metric_card, view: :thumbnail # , hide: :thumbnail_subtitle
  end

  # prominent value, less prominent year, legend, and markers
  view :concise, unknown: true do
    handle_unknowns { haml :concise }
  end

  view :year_and_icon do
    wrap_with :span, class: "answer-year" do
      "#{mapped_icon_tag :year} #{card.year}"
    end
  end

  view :not_researched, perms: :none, wrap: :em do
    "Not Researched"
  end

  view :research_option, perms: :none do
    card.known? ? render_concise : render_year_not_researched
  end

  view :year_not_researched, perms: :none, template: :haml

  view :breadcrumb, unknown: true, template: :haml

  view :comments do
    wrap_with :div, class: "comments-div mt-2" do
      field_nest :discussion,
                 view: :titled, title: "Comments", show: "comment_box", header: :h5
    end
  end

  # FIXME: Can do this with way less custom code
  view :homepage_answer_example, template: :haml do
    @company_image = nest company_card.image_card, size: :small
    @company_link =
      link_to_card card.company_card, card.answer.company, class: "inherit-anchor"
    @metric_image = nest metric_designer_card.try(:image_card), size: :small
    @metric_question = nest card.answer.metric, view: :title_and_question_compact
  end

  def edit_fields
    [
      [card.value_card, title: "Answer"],
      source_field_config,
      discussion_field_config
    ]
  end

  def source_field_config
    normalized_edit_field_config :source, title: "Source",
                                          input_type: :removable_content,
                                          view: :removable_content
  end

  def discussion_field_config
    normalized_edit_field_config :discussion, title: "Comments", show: :comment_box
  end

  def header_list_items
    metric = card.metric_card
    super.merge(
      "Metric Designer": link_to_card(metric.metric_designer),
      "Metric Title": link_to_card(metric, metric.metric_title)
    )
  end

  def handle_unknowns
    return yield if card.known?

    render(card.researchable? ? :research_button : :not_researched)
  end

  def company_thumbnail company, nest_args={}
    nest company, nest_args.merge(view: :thumbnail)
  end

  def edit_modal_size
    :full
  end
end
