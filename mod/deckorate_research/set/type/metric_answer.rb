# couldn't get this to work by adding it to abstract metric answer :(
include_set Abstract::DesignerPermissions

# this has to be on a type set for field events to work
require_field :value, when: :value_required?
require_field :source, when: :source_required?

delegate :value_required?, to: :metric_card

def unpublished_option?
  steward? && !metric_card.unpublished
end

# EVENTS
event :flash_success_message, :finalize, on: :create do
  success.flash format(:html).success_alert
end

format :html do
  view :header_middle, template: :haml

  view :header_right do
    render_flag_button
  end

  view :research_button, unknown: true do
    record_card.format.research_button year_name, (card.real? ? :answer_phase : nil)
  end

  view :flag_button do
    modal_link "Flag!",
               path: { mark: :flag,
                       action: :new,
                       card: { fields: { ":subject": card.name } } },
               class: "btn btn-outline-danger #{classy 'flag-button'}"
  end

  view :edit_inline do
    voo.buttons_view = :edit_answer_buttons
    super()
  end

  view :simple_new do
    voo.buttons_view = :submit_answer_button
    super()
  end

  view :submit_answer_button do
    button_formgroup { submit_answer_button }
  end

  view :edit_answer_buttons do
    button_formgroup do
      [submit_answer_button, cancel_answer_button, delete_button]
    end
  end

  view :read_form_with_button, wrap: :slot, template: :haml

  view :new do
    "Answers are created via the Research Page."
  end

  def cancel_answer_button
    link_to_view :read_form_with_button, "Cancel",
                 class: "btn btn-outline-secondary btn-lg btn-sm"
  end

  def delete_button
    super class: "btn-lg" if card.ok? :delete
  end

  def submit_answer_button
    standard_save_button text: "Submit Answer", class: "btn-lg"
  end

  def edit_fields
    super + [year_field, unpublished_field].compact
  end

  def year_field
    [:year, title: "Year"] if card.real? && @nest_mode == :edit
  end

  def unpublished_field
    [:unpublished, title: "Unpublished"] if card.unpublished_option?
  end

  def success_alert
    alert :success, true, false, class: "text-center" do
      haml :success_alert
    end
  end
end
