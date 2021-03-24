include_set Abstract::Variable
include_set Abstract::Pointer
include_set Abstract::MetricChild, generation: 1

def categorical?
  score? && metric_card.categorical?
end

def help_rule_card
  metric_card.metric_type_card.first_card&.fetch :help
end

format :html do
  def new_success
    { id: card.name.left }
  end

  def new_form_opts
    super().merge "data-slot-selector" => ".card-slot.TYPE-metric"
  end

  def edit_form_opts
    { "data-slot-selector" => ".card-slot.TYPE-metric" }
  end

  def edit_success
    new_success
  end

  view :input do
    with_hidden_content do
      _render card.metric_card.formula_editor
    end
  end

  def with_hidden_content
    hidden = card.metric_card.hidden_content_in_formula_editor?
    (hidden ? _render_hidden_content_field : "") + yield
  end

  view :standard_formula_editor, unknown: true do
    output [formula_text_area, _render_variables]
  end

  def formula_text_area
    text_area :content, rows: 5, class: "d0-card-content",
                        "data-card-type-code": card.type_code
  end

  view :core do
    render card.metric_card.formula_core
  end

  view :standard_formula_core, template: :haml, cache: :never

  def default_nest_view
    :bar
  end
end

event :validate_formula, :validate, when: :wolfram_formula?, changed: :content do
  formula_errors = calculator.detect_errors
  return if formula_errors.empty?
  formula_errors.each do |msg|
    errors.add :formula, msg
  end
end

def each_reference_out &block
  return super(&block) unless rating?
  translation_table.each do |key, _value|
    yield(key, Content::Chunk::Link::CODE)
  end
end

def replace_reference_syntax old_name, new_name
  return super unless rating?
  content.gsub old_name, new_name
end

def ruby_formula?
  calculator_class == ::Formula::Ruby
end

def translate_formula?
  calculator_class == ::Formula::Translation
end

def wolfram_formula?
  calculator_class ==  ::Formula::Wolfram
end
