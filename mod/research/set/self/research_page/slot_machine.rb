
format :html do
  view :slot_machine, cache: :never, perms: :create do
    slot_machine
  end

  def slot_machine opts={}
    %i[metric company project year active_tab].each do |n|
      if opts[n]
        instance_variable_set "@#{n}", opts[n]
      end
    end
    wrap do
      haml :slot_machine
    end
  end

  view :source_tab do
    wrap do
      haml :source_tab
    end
  end

  view :source_preview_tab do
    wrap do
      nest preview_source, view: :source_and_preview
    end
  end

  def preview_source
    params[:preview_source] || source
  end

  def source
    params[:source] || (answer? && answer_card.source_card.item_names.first)
  end

  def right_side_tabs
    tabs = {}
    if answer?
      tabs["Source"] = _render_source_tab
      tabs["Source preview"] = _render_source_preview_tab
    end
    tabs["Metric details"] = nest(metric, view: :details_tab_content,
                                      hide: [:add_value_buttons, :import_button])
    tabs["How to"] = nest(:how_to_research, view: :core)

    static_tabs tabs, active_tab
  end

  def add_source_form
    params[:company] = company
    nest Card.new(type_id: Card::SourceID), view: :new_research
  end

  def autocomplete_field type, options_card=nil
    codename = type == :company ? :wikirate_company : type
    options_card ||= Card::Name[codename, :type, :by_name]
    text_field_tag codename, "", class: "_research-select #{codename}_autocomplete form-control",
                   "data-options-card": options_card,
                   "data-url": research_url,
                   "data-key": type,
                   placeholder: type.to_s.capitalize
  end

  def active_tab
    @active_tab ||= params[:active_tab]
  end

  def company_list
    list_from_project_or_params(:company) || [] #card.wikirate_company_card.item_names
  end

  def metric_list
    list_from_project_or_params(:metric) || [] #card.metric_card.item_names
  end

  def year_list
    list_from_project_or_params(:year) || years
  end

  def list_from_project_or_params name
    list_name = "#{name}_list"
    (params[list_name] && Array(params[list_name])) ||
        (params[name] && Array(params[name])) ||
        (project_card && project_card.send(list_name))
  end

  def research_url opts={}
    path_opts = { view: :slot_machine }

    %i[metric company year].each do |i|
      val = opts[:metric] || send(i)
      path_opts[i] = val if val
    end

    if project
      path_opts[:project] = project
    else
      path_opts[:metric_list] = metric_list
      path_opts[:company_list] = company_list
      path_opts[:year_list] = year_list
    end
    path path_opts
  end

  def years
    Card.search(type_id: YearID, return: :name, sort: :name, dir: :desc).map(&:to_i)
  end



  def source_form_url
    path action: :new, mark: :source, preview: true, company: company
  end

  def answer_view
    answer_card.new_card? ? :research_form : :titled
  end

  def metric?
    Card.fetch_type_id(metric) == MetricID
  end

  def metric
    @metric ||= Env.params[:metric] || metric_list.first
  end

  def company?
    Card.fetch_type_id(company) == WikirateCompanyID
  end

  def answer?
    metric && company && year
  end

  def company
    @company ||= Env.params[:company] || company_list.first
  end

  def no_company?
    !company
  end

  def year
    @year ||= Env.params[:year] || year_list.first
  end

  def record_card
    @src ||= Card.fetch [metric, company], new: { type_id: RecordID }
  end

  def answer_card
    @sac ||= Card.fetch [metric, company, year.to_s], new: { type_id: MetricValueID }
  end

  def metric_pinned?
    metric_list.empty? || metric_list.one?
  end

  def company_pinned?
    company_list.empty? || company_list.one?
  end

  def year_pinned?
    year_list.empty? || year_list.one?
  end
end
