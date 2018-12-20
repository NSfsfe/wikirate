 module Formula
  # Formula that translates one value to another based on a JSON map
  class Translation < Calculator
    def get_value input, _company, _year
      if input.size > 1
        raise Card::Error,
              "translate formula with more than one metric involved"
      end
      # For multi-category metrics we map every
      Array.wrap(input.first).inject(0.0) do |res, inp|
        res + (@executed_lambda[inp.to_s.downcase] || @executed_lambda["else"]).to_f
      end
    end

    def to_lambda
      @parser.formula.downcase
    end

    # Is this the right class for this formula?
    def self.supported_formula? formula
      formula =~ /^\{[^{}]*\}$/
    end

    def year_options
      nil
    end

    protected

    def exec_lambda expr
      JSON.parse expr
    rescue JSON::ParserError => _e
      @errors << "invalid translation formula #{expr}"
    end

    def safe_to_convert? expr
      self.class.supported_formula? expr
    end

    def safe_to_exec? _expr
      true
    end
  end
end
