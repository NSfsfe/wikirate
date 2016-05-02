class Formula
  class Input
    def initialize calculator, formula
      @calculator = calculator
      @all_fetched = false
      @year_args_processor = YearArgsProcessor.new formula
    end

    def each opts={}
      fetch_values opts
      years = opts[:year] ? Array(opts[:year]) : years_with_values
      years.each do |year|
        companies_with_value(year).each do |company_key|
          next unless (value = input_for(year, company_key))
          yield(value, company_key, year)
        end
      end
    end

    def type index
      @order[index][1]
    end

    def key index
      @order[index][0]
    end

    def companies_with_value year
      @companies_with_values_by_year[year].to_a
    end

    def years_with_values
      @companies_with_values_by_year.keys
    end

    # @param [Integer] year the year the value is calculated for
    # @param [Array] value_data an array with a hash for every metric nest in the
    # formula in order of appearance. The hashes must have the form
    # { year => value }
    # @return an array with the input for every metric in the formula
    def input year=nil, company=nil
      if year && company
        input_for year, company
      else
        result = Hash.new_nested Hash
        each do |ip, company, year|
          result[year][company] = ip
        end
      end
    end

    def input_for year, company
      fetch_values company: company, year: year unless @all_fetched
      values_for_all_years = all_values_for company.to_name.key
      values = @year_args_processor.run values_for_all_years, year
      validate_input values
    end

    private

    def validate_input input
      input.map do |val|
        if val.is_a?(Array)
          val.map do |v|
            return if v.blank?
            @calculator.cast_input v
          end
        else
          return if val.blank?
          @calculator.cast_input val
        end
      end
    end

    def fetch_values opts={}
      return if @all_fetched
      @all_fetched ||= opts.empty?

      @metric_values = Hash.new_nested Hash, Hash
      @yearly_values = Hash.new_nested Hash

      @companies_with_values =
        opts[:company] ? [opts[:company].to_name.key] : nil
      @companies_with_values_by_year = Hash.new_nested ::Set
      @order = []

      @calculator.each_input_card do |input_card|
        case input_card.type_id
        when Card::MetricID
          metric_value_fetch input_card, opts
          @order << [input_card.key, input_card.value_type]
        when Card::YearlyVariableID
          yearly_value_fetch input_card
          @order << [input_card.key, :yearly_value]
        end
        if @companies_with_values.empty?
          @companies_with_values_by_year = {}
          return
        end
      end
    end

    def metric_value_fetch input_card, opts={}
      search_restrictions = {
        metrics: input_card.name.to_s,
        companies: @companies_with_values
      }
      if opts[:year] && !@year_args_processor.multi_year
        search_restrictions[:year] = opts[:year]
      end
      v_cards = input_metric_value_cards search_restrictions

      filter_companies v_cards.map(&:company_key)

      v_cards.each do |vc|
        @metric_values[vc.metric_key][vc.company_key][vc.year.to_i] = vc.value
        @companies_with_values_by_year[vc.year.to_i] << vc.company_key
      end
    end

    def filter_companies company_keys
      @companies_with_values =
        if @companies_with_values
          @companies_with_values & company_keys
        else
          company_keys
        end
    end

    def yearly_value_fetch input_card
      v_cards = input_yearly_value_cards(variables: input_card.name)
      v_cards.each do |vc|
        @yearly_values[input_card.key] = vc.content
        @companies_with_values_by_year[vc.year.to_i] << input_card.key
      end
    end

    def all_values_for company, year=nil
      @order.map do |name, type|
        val =
          case type
          when :yearly_value
            @yearly_values[name]
          else
            @metric_values[name][company]
          end
        return nil unless val
        year ? val[year] : val
      end
    end

    # Searches for all metric value cards that are necessary to calculate all values
    # If a company (and a year) is given it returns only the metric value cards that
    # are needed to calculate the value for that company (and that year)
    # @param [Hash] opts ({})
    # @option [String] :company
    # #option [String] :year
    def input_metric_value_cards opts={}
      ::Card.search metric_value_cards_query(opts)
    end

    def input_yearly_value_cards opts={}
      ::Card.search yearly_value_cards_query(opts)
    end

    def metric_value_cards_query opts={}
      left_left = {}
      if opts[:metrics].present?
        left_left[:left] = { name: ['in'] + Array.wrap(opts[:metrics]) }
      end
      if opts[:companies].present?
        left_left[:right] = { name: ['in'] + Array.wrap(opts[:companies]) }
      end
      query = { right: 'value', left: { type_id: Card::MetricValueID } }
      query[:left][:left] = left_left if left_left.present?
      query[:left][:right] = opts[:year].to_s if opts[:year]
      query
    end

    def yearly_value_cards_query opts={}
      query =  { type_id: Card::YearlyValueID }
      if opts[:variables]
        query[:left] = { name: ['in'] + Array.wrap(opts[:variables]) }
      end
      query
    end
  end
end