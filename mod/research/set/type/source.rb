format :html do
  view :new_research, tags: :unknown_ok do
    with_nest_mode :edit do
      voo.type = "source"
      card_form :create, "main-success" => "REDIRECT",
                         "data-form-for" => "new_metric_value",
                         class: "slotter new-view TYPE-source" do
        output [
                 new_research_hidden,
                 new_view_type,
                 haml(:source_form),
                 new_research_buttons
               ]
      end
    end
  end

  def new_research_hidden
    hidden_tags success: { id: ":research_page", soft_redirect: true, view: :source_tab },
                card: { subcards: { "+company": { content: Env.params[:company] } } },
                source: Env.params[:source]
  end

  def new_research_buttons
    button_formgroup do
      wrap_with :button, "Add", class: "btn btn-primary pull-right",
                                data: { disable_with: "Adding" }
    end
  end
end
