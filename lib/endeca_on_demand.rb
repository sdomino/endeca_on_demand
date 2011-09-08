require 'endeca_on_demand/proxy'

Dir["#{File.dirname(__FILE__)}/endeca_on_demand/*"].each { |file| require(file)}

require 'builder'
require 'nokogiri'
require 'net/http'
require 'uri'

class EndecaOnDemand
  
  def initialize(host, options)
    unless host.blank?
      @body = Builder::XmlMarkup.new(:indent => 2)

      #
      set_host(host)
      
      #
      options.each do |key, value|
        self.send(key.to_sym, value) unless value.empty?
      end
      
      #
      send_request
      
      self.instance_variables.each do |instance_variable|
        # puts "VARS: #{instance_variable}"
        # self.class_eval("attr_reader :#{instance_variable}")
      end
    else
      puts "Unable to continue... Make sure \"#{host}\" is a valid thanxmedia host."
    end
  end
  
  ### API
    attr_reader :records, :record_offset, :records_per_page, :total_record_count
    attr_reader :breadcrumbs, :filtercrumbs
    attr_reader :dimensions
    attr_reader :rules
    attr_reader :searches, :matchedrecordcount, :matchedmode, :applied_search_adjustments, :suggested_search_adjustments
    attr_reader :selected_dimension_value_ids
  
    ## DEBUG
      attr_reader :uri, :http
      attr_reader :base, :query, :request, :raw_response, :response, :error
    ## /DEBUG
  ### /API
  
  def success?
    @error.blank?
  end
  
  private
  
  def method_missing(method, *args, &block)
    unless self.instance_variables.include?(:"@#{method}")
      puts "#{method} is unavailable."
    else
      puts "Unable to retrieve #{method} because: #{@error.message}."
    end
  end
  
  ## SEND REQUEST
  
  # Completes the endeca XML reqeust by inserting the XML body into the requred 'Query' tags, and sends the request to your hosted Endeca On-Demand Web API
  def send_request
    @query = Builder::XmlMarkup.new(:indent => 2)
    @query.Query do
      @query << @body.target!
    end
    
    begin
      @request, @raw_response = @http.post(@uri.path, @query.target!, 'Content-type' => 'application/xml')
      handle_response(Nokogiri::XML(@raw_response))
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => error
      @error = error
    end
  end
  
  ## HANDLE RESPONSE

  def handle_response(response)
    @response = response
    
    build_records
    build_breadcrumbs
    build_dimensions
    build_business_rules
    build_applied_filters
  end
  
  ### XML REQUEST ###
  
  ## SET REQUEST HOST
  def set_host(host)
    @uri  = URI.parse(host)
    @http = Net::HTTP.new(@uri.host, @uri.port)
  end
  
  ## ADD BASE OPTIONS TO REQUEST
  def add_base(options)
    options.each do |key, value|
      @body.tag!(key, value)
    end
    
    @base = options
  end
  
  ## BUILD REQUEST BODY
  
  # Adds dimension_value_id_navigation to the request via one or more DimensionValueIds (DVID).
  # NOTE: If the optional CategoryId (CID) is passed, all DVIDs must belong to the category.
  def add_dimension_value_id_navigation(options)
    @body.SelectedDimensionValueIds do
      options.each do |option|
        @body.tag!('DimensionValueId', option)
      end
    end
  end
  
  # (OPTIONAL) Adds category_navigation_query to the request via a CID.
  # NOTE: If a CID is passed, all DVIDs must belong to the category. Passing a DVID that does not belong to this category will result in an endeca response error.
  def add_category_navigation_query(options)
    @body.Category do
      @body.tag!('CategoryId', options)
    end
  end
  
  # Adds search-key and search-term to the request.
  def add_keyword_search(options)
    @body.Searches do
      @body.Search do
        options.each do |key, value|
          @body.tag!(key, value)
        end
      end
    end
  end
  
  # Adds sort-key and sort-direction to the request.
  def add_sorting(options)
    @body.Sorts do
      @body.Sort do
        options.each do |key, value|
          @body.tag!(key, value)
        end
      end
    end
  end
  
  # Adds RecordOffset and RecordsPerPage to the request.
  def add_paging(options)
    options.each do |key, value|
      @body.tag!(key, value)
    end
  end
  
  # Adds advanced parameters to the request.
  # NOTE: For this implementation I only had the default advanced parameter (AggregationKey) to test with. This has not been tested, and most likely will not work, with any other possible advanced parameters (if any)
  def add_advanced_parameters(options)
    options.each do |key, value|
      @body.tag!(key, value)
    end
  end
  
  # Adds UserProfile(s) to the request.
  def add_profiles(options)
    @body.UserProfiles do
      options.each do |option|
        @body.tag!('UserProfile', option)
      end
    end
  end
  
  #
  def add_filters(options)
    # puts "FILTERS: #{options}"
    @body.RangeFilters do
      options.each do |key, value|
      # puts "#{key}: #{value}"
        @body.tag!(key, value) do
          value.each do |key, value|
            @body.tag!(key, value)
          end
        end unless value.empty?
      end
    end
    # puts @body.target!
  end
  
  ### RESPONSE XML ###
  
  ## BUILD RESPONSE
  
  # Builds an array of RECORDS
  def build_records
    @records = []
    
    @record_offset = @response.xpath("//RecordsSet//offset")
    @records_per_page = @response.xpath("//RecordsSet//recordsperpage")
    @total_record_count = @response.xpath("//RecordsSet//totalrecordcount")
    
    unless @response.xpath("//RecordsSet").nil?
      @response.xpath("//RecordsSet//Record").each do |record|
        @records.push(EndecaOnDemand::Record.new(record))
      end
    else
      puts 'There are no records with this response!'
    end
  end
  
  # Builds an array of BREADCRUMBS
  def build_breadcrumbs
    @filtercrumbs = []
    @breadcrumbs  = []

    unless @response.xpath("//Breadcrumbs").nil?
      @response.xpath("//Breadcrumbs//Breads").each do |node|
        filtercrumbs = []
        node.xpath("./Bread").each do |node|
          breadcrumb = EndecaOnDemand::BreadCrumb.new(node)
          filtercrumbs.push(breadcrumb)
          @breadcrumbs.push(breadcrumb)
        end
        @filtercrumbs.push(filtercrumbs)
      end
    else  
      puts 'There are no breadcrumbs with this response!'
    end
  end
  
  # Builds an array of DIMENSIONS
  def build_dimensions
    @dimensions = []
    
    unless @response.xpath("//Dimensions").nil?
      @response.xpath("//Dimensions//Dimension").each do |node|
        @dimensions.push(EndecaOnDemand::Dimension.new(node))
      end
    else
      puts 'There are no dimensions with this response!'
    end
  end
  
  # Builds an array of BUSINESS RULES
  def build_business_rules
    @business_rules_results = []
    
    unless @response.xpath("//BusinessRulesResult").nil?
      @response.xpath("//BusinessRulesResult//BusinessRules//BusinessRule").each do |node|
        @business_rules_results.push(EndecaOnDemand::BusinessRulesResult.new(node))
      end
    else
      puts 'There are no business rules with this response!'
    end
  end
    
  # Builds the SEARCH REPORTS and SELECTED DIMENSION VALUE IDS if included in response
  def build_applied_filters
    unless @response.xpath("//AppliedFilters").nil?

      # Builds an array of SEARCH REPORTS
      unless @response.xpath("//AppliedFilters//SearchReports").nil?
        @searches = []
    
        @matchedrecordcount             = @response.xpath("//AppliedFilters//SearchReports//SearchReport//matchedrecordcount")
        @matchedmode                    = @response.xpath("//AppliedFilters//SearchReports//SearchReport//matchedmode")
        @matchedtermscount              = @response.xpath("//AppliedFilters//SearchReports//SearchReport//matchedtermscount")
        @applied_search_adjustments     = @response.xpath("//AppliedFilters//SearchReports//SearchReport//AppliedSearchAdjustments")
        @suggested_search_adjustments   = @response.xpath("//AppliedFilters//SearchReports//SearchReport//SuggestedSearchAdjustments")
    
        @searches.push(EndecaOnDemand::Search.new(@response.xpath("//AppliedFilters//SearchReports//SearchReport//Search")))
      else
        puts 'There are no search reports with this response!'
      end

      # Builds an array of SELECTED DIMENSION VALUE IDS
      unless @response.xpath("//AppliedFilters//SelectedDimensionValueIds").nil?
        @selected_dimension_value_ids = []
    
        @response.xpath("//AppliedFilters//SelectedDimnesionValueIds").each do |node|
          @selected_dimension_value_ids.push(EndecaOnDemand::SelectedDimensionValueId.new(node))
        end
      else
        puts "There are no selected dimension value ids with this response!"
      end
    else
      puts 'There were not applied filters with this response!'
    end
  end
  
end
