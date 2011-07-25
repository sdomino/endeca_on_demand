Dir["#{File.dirname(__FILE__)}/endeca_on_demand/*"].each { |file| require(file)}

require 'builder'
require 'crackoid'
require 'net/http'
require 'uri'

class EndecaOnDemand
  
  def initialize(host, options)
    @body = Builder::XmlMarkup.new(:indent => 2)

    #
    set_host(host)
    
    #
    options.each do |key, value|
      self.send(key.to_sym, value) unless value.empty?
    end
    
    #
    send_request
  end
  
  ### API
  
  attr_reader :records, :record_offset, :records_per_page, :total_record_count
  attr_reader :breadcrumbs, :filtercrumbs
  attr_reader :dimensions
  attr_reader :rules
  attr_reader :searchs, :matchedrecordcount, :matchedmode, :applied_search_adjustments, :suggested_search_adjustments
  attr_reader :selected_dimension_value_ids
  
  ## DEBUG
  attr_reader :uri, :http
  attr_reader :base, :query, :request, :raw_response, :response
  ## /DEBUG
  
  ### /API
  
  private
  
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
      options.each do |dimension|
        @body.tag!('DimensionValueId', dimension)
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
      options.each do |profile|
        @body.tag!('UserProfile', profile)
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
  
  ## SEND REQUEST
  
  # Completes the endeca XML reqeust by inserting the XML body into the requred 'Query' tags, and sends the request to your hosted Endeca On-Demand Web API
  def send_request
    @query = Builder::XmlMarkup.new(:indent => 2)
    @query.Query do
      @query << @body.target!
    end
    
    begin
      @request, @raw_response = @http.post(@uri.path, @query.target!, 'Content-type' => 'application/xml')
      handle_response(Crackoid::XML.parse(@raw_response))
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => error
      puts "ERROR: #{error.message}"
    end
  end
  
  ## HANDLE RESPONSE

  def handle_response(response)
    @response = response['Final']
    
    build_data
  end
  
  def build_data
    build_records
    build_breadcrumbs
    build_filtercrumbs
    build_dimensions
    build_business_rules
    build_applied_filters
  end
  
  # Builds an array of RECORDS
  def build_records
    @records = []
    
    record_set = @response['RecordsSet']
    
    @record_offset = record_set.fetch('offset')
    @records_per_page = record_set.fetch('recordsperpage')
    @total_record_count = record_set.fetch('totalrecordcount')
    
    unless record_set.nil?
      record = @response['RecordsSet']['Record']
      if record.instance_of?(Hash)
        @records.push(EndecaOnDemand::Record.new(record_set))
      elsif record.instance_of?(Array)
        record.each do |record|
          @records.push(EndecaOnDemand::Record.new(record))
        end
      end
    else
      puts 'There are no records with this response!'
    end
  end
  
  # Builds an array of BREADCRUMBS
  def build_breadcrumbs
    @breadcrumbs  = []
    
    breadcrumbs = @response['Breadcrumbs']
    unless breadcrumbs.nil?
      breads = @response['Breadcrumbs']['Breads']
      if breads.instance_of?(Hash)
        bread = breads['Bread']
        if bread.instance_of?(Hash)
          bread.each do |key, value|
            @breadcrumbs.push(EndecaOnDemand::Crumb.new(bread))
          end
        elsif bread.instance_of?(Array)
          bread.each do |crumb|
            @breadcrumbs.push(EndecaOnDemand::Crumb.new(crumb))
          end
        end
      elsif breads.instance_of?(Array)
        breads.each do |breadz|
          bread = breadz['Bread']
          if breadz.instance_of?(Hash)
            if bread.instance_of?(Hash)
              bread.each do |key, value|
                @breadcrumbs.push(EndecaOnDemand::Crumb.new(bread))
              end
            elsif bread.instance_of?(Array)
              bread.each do |crumb|
                @breadcrumbs.push(EndecaOnDemand::Crumb.new(crumb))
              end
            end
          elsif breadz.instance_of?(Array)
            bread.each do |crumb|
              @breadcrumbs.push(EndecaOnDemand::Crumb.new(crumb))
            end
          end
        end
      end
    else  
      puts 'There are no breadcrumbs with this response!'
    end
  end
  
  # Builds an array of FILTERCRUMBS (BREADCRUMBS used as left nav filterables)
  def build_filtercrumbs
    @filtercrumbs = []
    
    breads = @response['Breadcrumbs']['Breads']
    if breads.instance_of?(Hash)
      breads.each do |key, value|
        @filtercrumbs.push(value)
      end
    elsif breads.instance_of?(Array)
      breads.each do |bread|
        if bread.instance_of?(Hash)
          @filtercrumbs.push(bread['Bread'])
        elsif bread.instance_of?(Array)
          bread['Bread'].each do |crumb|
            @filtercrumbs.push(crumb)
          end
        end
      end
    end
  end
  
  # Builds an array of DIMENSIONS
  def build_dimensions
    @dimensions = []
    
    dimensions = @response['Dimensions']
    unless @response['Dimensions'].nil?
      dimension = @response['Dimensions']['Dimension']
      if dimension.instance_of?(Hash)
        @dimension = EndecaOnDemand::Dimension.new(dimensions)
        add_dimension_values(dimension)
      elsif dimension.instance_of?(Array)
        dimension.each do |dimension|
          @dimension = EndecaOnDemand::Dimension.new(dimension)
          add_dimension_values(dimension)
        end
      end
    else
      puts 'There are no dimensions with this response!'
    end
  end
  
  # Adds an array of DIMENSION VALUES to each DIMENSION
  def add_dimension_values(dimension)
    unless dimension['DimensionValues'].nil?
      if dimension['DimensionValues']['DimensionValue'].instance_of?(Hash)
        @dimension.dimension_values.push(EndecaOnDemand::Dimension.new(dimension['DimensionValues']))
      elsif dimension['DimensionValues']['DimensionValue'].instance_of?(Array)
        dimension['DimensionValues']['DimensionValue'].each do |dimension_value|
          @dimension.dimension_values.push(EndecaOnDemand::Dimension.new(dimension_value))
        end
      end
      @dimensions.push(@dimension)
    else
      puts "There are no dimension values on this dimension!"
    end
  end
  
  # Builds an array of BUSINESS RULES
  def build_business_rules
    @business_rules = []
    
    business_rules_result = @response['BusinessRulesResult']
    unless business_rules_result.nil?
      business_rules = @response['BusinessRulesResult']['BusinessRules']
      if business_rules.instance_of?(Hash)
        business_rule = EndecaOnDemand::Rule.new(business_rules)
        business_rules.each do |key, value|
          add_business_rule_properties(value) if key == 'properties'
          add_business_rule_records(value) if key == 'RecordSet'
        end
      elsif business_rules.instance_of?(Array)
        @response['BusinessRulesResult']['BusinessRules']['BusinessRule'].each do |rule|
          business_rule = EndecaOnDemand::Rule.new(rule)
          rule.each do |key, value|
            add_business_rule_properties(key) if key == 'properties'
            add_business_rule_records(key) if key == 'RecordSet'
          end
        end
      end
      @business_rules.push(business_rule)
    else
      puts 'There are no business rules with this response!'
    end
  end
  
  # Adds an array of PROPERTIES to each BUSINESS RULE
  def add_business_rule_properties(value)
    @business_rule.properties_array.push(EndecaOnDemand::Rule.new(value)) unless value.nil?
  end
  
  # Adds an array of RECORDS to each BUSINESS RULE
  def add_business_rule_records(value)
    @business_rule.records.push(EndecaOnDemand::Record.new(value['Record'])) unless value.nil?
  end
  
  # Builds the SEARCH REPORTS and SELECTED DIMENSION VALUE IDS if included in response
  def build_applied_filters
    unless @response['AppliedFilters'].nil?
      unless @response['AppliedFilters']['SearchReports'].nil?
        build_search_reports
      else
        puts 'There are no search reports with this response!'
      end
      unless @response['AppliedFilters']['SelectedDimensionValueIds'].nil?
        build_selected_dimension_value_ids
      else
        puts "There are no selected dimension value ids with this response!"
      end
    else
      puts 'There were not applied filters with this response!'
    end
  end
  
  # Builds an array of SEARCH REPORTS
  def build_search_reports
    @searchs = []
    
    search_report = @response['AppliedFilters']['SearchReports']['SearchReport']
    
    @matchedrecordcount           = search_report.fetch('matchedrecordcount')
    @matchedmode                  = search_report.fetch('matchmode')
    @matchedtermscount            = search_report.fetch('matchedtermscount')
    @applied_search_adjustments   = search_report.fetch('AppliedSearchAdjustments')
    @suggested_search_adjustments = search_report.fetch('SuggestedSearchAdjustments')
    
    @searchs.push(EndecaOnDemand::Search.new(search_report.fetch('Search')))
  end
  
  # Builds an array of SELECTED DIMENSION VALUE IDS
  def build_selected_dimension_value_ids
    @selected_dimension_value_ids = []
    
    selected_dimension_value_ids = @response['AppliedFilters']['SelectedDimensionValueIds']
    if selected_dimension_value_ids.instance_of?(Hash)
      selected_dimension_value_id = EndecaOnDemand::DimensionValueId.new(selected_dimension_value_ids)
    elsif selected_dimension_value_ids.instance_of?(Array)
      selected_dimension_value_ids.each do |key, value|
        selected_dimension_value_id = EndecaOnDemand::DimensionValueId.new(value)
      end
    end
    @selected_dimension_value_ids.push(selected_dimension_value_id)
  end
  
end
