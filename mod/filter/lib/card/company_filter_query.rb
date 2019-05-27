class Card
  class CompanyFilterQuery < FilterQuery
    def company_wql company
      name_wql company
    end
    alias wikirate_company_wql company_wql

    def topic_wql value
      add_to_wql :found_by, value.to_name.trait_name(:wikirate_company).trait(:refers_to)
    end
    alias wikirate_topic_wql topic_wql

    def project_wql project
      return unless project.present?
      @filter_wql[:referred_to_by] << { left: project, right: :wikirate_company }
    end
  end
end
