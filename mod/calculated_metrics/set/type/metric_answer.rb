
# The answers that a calculated answer depends on
# @return [Array] array of Answer objects
def direct_dependee_answers
  return [] if researched_value?

  metric_card.calculator.answers(company: company_id, year: year).uniq
end

def dependee_answers
  direct_dependee_answers.tap do |answers|
    answers << answers.map(&:dependee_answers)
    answers.flatten!.uniq!
  end
end

def researched_dependee_answers
  dependee_answers.select(&:researched_value?)
end

def each_depender_answer
  metric_card.each_depender_metric do |metric|
    answer = Answer.where(metric_id: metric, company_id: company_id, year: year).take
    yield answer if answer.present?
  end
end
