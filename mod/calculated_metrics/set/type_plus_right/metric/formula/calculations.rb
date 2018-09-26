
event :flag_metric_answer_calculation, :prepare_to_store, on: :update, changed: :content do
  metric_card.calculation_in_progress!
end

# don't update if it's part of scored metric update
event :update_metric_answers, :integrate_with_delay, on: :update, changed: :content do
  metric_card.deep_answer_update
end

event :create_dummy_answers, :finalize,
      on: :create, changed: :content, when: :content? do
  Answer.bulk_insert values: dummy_answers_attribs
end

# don't update if it's part of scored metric create
event :create_metric_answers, :integrate_with_delay,
      on: :create, changed: :content, when: :content?  do
  # reload set modules seems to be no longer necessary
  # it used to happen at this point that left has type metric but
  # set_names includes "Basic+formula+*type plus right"
  # reset_patterns
  # include_set_modules
  metric_card.deep_answer_update true
end

delegate :calculator, to: :metric_card

def dummy_answers_attribs
  calculator.answers_to_be_calculated.map do |company_id, year|
    unless Card[metric_card, company_id]
      Card.create! name: [metric_card, company_id], type_id: Card::RecordID
    end
    { metric_id: metric_card.id, company_id: company_id, year: year, calculating: true,
      metric_name: metric_card.name, latest: true }
  end
end

def regenerate_answers
  replace_existing_answers
  create_metric_answers
end

def calculator
  @calculator ||= calculator_class.new self
end

def calculator_class
  ::Formula.calculator_class(clean_formula)
end



