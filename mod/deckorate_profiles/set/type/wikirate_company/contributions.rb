include_set Abstract::ProfileType

card_reader :projects_organized, type: :search_type
card_reader :metrics_designed, type: :search_type
card_reader :research_group, type: :search_type

format :html do
  def contrib_page?
    @contrib_page.nil? ? (@contrib_page = contrib_page_from_params?) : @contrib_page
  end

  view :metrics_designed_tab do
    field_nest :metrics_designed, view: :titled
  end

  view :research_group_tab do
    field_nest :research_group, view: :content
  end

  view :projects_organized_tab do
    field_nest :projects_organized, view: :content
  end

  # NOCACHE because of special contributor handling
  view :type_link, cache: :never do
    super()
  end

  view :contrib_switch, cache: :never do
    return "" unless contribs_made?

    contrib_page? ? switch_to_performance : switch_to_contrib
  end

  def switch_to_performance
    switch_to "Performance", :wikirate_company, "N", "Company performance profile"
  end

  def switch_to_contrib
    switch_to "Contributions", :user, "Y", "Content contributions to WikiRate.org"
  end

  def switch_to text, icon, val, title
    text = wrap_with :div, class: "text-secondary" do
      "#{mapped_icon_tag icon} See #{text}"
    end
    link_to_card card, text,
                 class: "company-switch", title: title, path: { contrib: val }
  end

  def type_link_label
    contrib_page? ? "Organizational Contributor" : super
  end

  def type_link_icon
    mapped_icon_tag(contrib_page? ? :user : :wikirate_company)
  end

  def contribs_made?
    Card.cache.fetch "#{card.id}-CONTRIB" do
      metrics_designed? # || research_groups_organized? || projects_organized?
      # only updates with cache clearing.  fine for now...
    end
  end

  def research_groups_organized?
    card.research_group_card.count.positive?
  end

  def metrics_designed?
    card.metrics_designed_card.count.positive?
  end

  def projects_organized?
    card.projects_organized_card.count.positive?
  end

  private

  def contrib_page_from_params?
    param = Env.params[:contrib]
    contribs_made? ? param != "N" : param == "Y"
  end
end
