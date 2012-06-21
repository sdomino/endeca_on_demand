module EndecaOnDemand
  class Response
    class AppliedFilters < EndecaOnDemand::Proxy

      include EndecaOnDemand::PP

      def inspect_attributes; [ :search_reports, :selected_dimension_value_ids ]; end

      ## fields ##

      attr_reader :response, :search_reports

      def initialize(response, xml)
        @response, @xml = response, xml
      end

      ## override proxy ##

      def class
        EndecaOnDemand::Response::AppliedFilters
      end

      ##

      ## associations ##

      def search_reports
        @search_reports ||= EndecaOnDemand::Collection.new(EndecaOnDemand::Response::AppliedFilters::SearchReport, xml.children.css('SearchReports > SearchReport'), self)
      end

      def selected_dimension_value_ids
        @selected_dimension_value_ids ||= EndecaOnDemand::Collection.new(EndecaOnDemand::Response::AppliedFilters::SelectedDimensionValueId, xml.children.css('SelectedDimensionValueIds > DimensionValueId'), self)
      end

      ##
      
    end
  end
end

require 'endeca_on_demand/response/applied_filters/search_report'
require 'endeca_on_demand/response/applied_filters/selected_dimension_value_id'