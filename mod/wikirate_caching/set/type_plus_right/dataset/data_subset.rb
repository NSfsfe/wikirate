# subprojects tagged with this project (=left) via <project>+parent
include_set Abstract::SearchCachedCount

# does not quite fit the Abstract::TaggedByCachedCount pattern, because the cached
# count is on project+subproject, not project+project

recount_trigger :type_plus_right, :project, :parent do |changed_card|
  changed_card.changed_item_names.map do |item_name|
    Card.fetch item_name.to_name.trait :subproject
  end
end

define_method :cql_hash do
  { type_id: ProjectID, right_plus: [ParentID, { refer_to: left.id }] }
end
