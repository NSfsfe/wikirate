# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::MetricAnswer::Listings do
  # TODO: move this to where humanized_number is actually defined.
  describe "#humanized_number" do
    def humanize number
      Card["Jedi+deadliness+Death Star+1977"].format.humanized_number(number)
    end

    specify do
      expect(humanize("1_000_001")).to eq "1M"
    end
    specify do
      expect(humanize("0.00000123345")).to eq "0.00000123"
    end
    specify do
      expect(humanize("0.001200")).to eq "0.0012"
    end
    specify do
      expect(humanize("123.4567")).to eq "123.5"
    end
  end

  describe "view :concise" do
    def concise_answer_for metric_title
      render_view :concise, name: "#{metric_title}+Sony Corporation+2010"
    end

    context "with multi category metric" do
      subject { concise_answer_for "Joe User+big multi" }

      it "has comma separated list of values" do
        is_expected.to have_tag "span.metric-value", "1, 2"
      end
      it "has correct year" do
        is_expected.to have_tag "span.metric-year", /2010/
      end
      it "has options" do
        with_tag :a, with: { href: "/half_year+Slate_Rock_and_Gravel_Company+2004" },
                     text: "1002"
        is_expected.to have_tag "span.metric-unit" do
          with_tag "small" do
            with_tag "i.fa.fa-list"
            text: "1, <br>2, <br>3, <br>4, <br>5, <br>6, <br>7, <br>8, <br>9, <br>10, <br>11"
            with_tag "a.pl-1.text-muted-link.border.text-muted.px-1" do
              with_tag "i.fa.fa-ellipsis-h"
            end
          end
        end
      end
    end

    context "with single category metric" do
      subject { concise_answer_for "Joe User+big single" }

      it "has value" do
        is_expected.to have_tag "span.metric-value", "4"
      end
      it "has correct year" do
        is_expected.to have_tag "span.metric-year", /2010/
      end
      it "has options" do
        is_expected.to have_tag "span.metric-unit" do
          with_tag "small" do
            with_tag "i.fa.fa-list"
            text: "1, <br>2, <br>3, <br>4, <br>5, <br>6, <br>7, <br>8, <br>9, <br>10, <br>11"
            with_tag "a.pl-1.text-muted-link.border.text-muted.px-1" do
              with_tag "i.fa.fa-ellipsis-h"
            end
          end
        end
      end
    end
  end
end
