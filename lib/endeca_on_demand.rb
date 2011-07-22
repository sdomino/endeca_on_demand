Dir["#{File.dirname(__FILE__)}/endeca_on_demand/*"].each { |file| require(file)}

require 'builder'
require 'crackoid'
require 'net/http'
require 'uri'

class EndecaOnDemand
  
  def initialize(host, options)
    @body = Builder::XmlMarkup.new(:indent => 2)

    #
    # puts "HOST: #{host}"
    set_host(host)
    
    #
    # puts "OPTIONS: #{options}"
    options.each do |key, value|
      self.send(key.to_sym, value) unless value.empty?
    end
    
    #
    send_request
  end
  
  ### API
  
  def records
    @records
  end
  
  def breadcrumbs
    @breadcrumbs
  end
  
  def filtercrumbs
    @filtercrumbs
  end
  
  def dimensions
    @dimensions
  end
  
  def rules
    @business_rules
  end
  
  def search_reports
    @search_reports
  end
  
  def selected_dimension_value_ids
    @selected_dimension_value_ids
  end
  
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
  
  #
  def add_advanced_parameters(options)
    # puts "PARAMETERS: #{options}"
    options.each do |key, value|
      @body.tag!(key, value)
    end
    # puts @body.target!
  end
  
  # Adds UserProfile(s) to the request.
  #TODO: test and see what happens if profiles are passed and don't exist
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
    # insert all of the XML blocks that have been included in the request into the endeca Query XML tag
    query = Builder::XmlMarkup.new(:indent => 2)
    query.Query do
      query << @body.target!
    end

    # puts "QUERY: #{query.target!}"

    begin
      request, response = @http.post(@uri.path, query.target!, 'Content-type' => 'application/xml')
      handle_response(Crackoid::XML.parse(response))
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => error
      puts "ERROR: #{error.message}"
    end
  end
  
  ## HANDLE RESPONSE

  # get the request response and parse it into an hash
  def handle_response(response)
    # puts "RESPONSE: #{response}"
    @response = response['Final']

    build_data
  end
  
  def build_data
    build_records
    build_breadcrumbs
    build_dimensions
    build_business_rules
    build_search_reports
    build_selected_dimension_value_ids
  end
  
  # builds the RECORDS hash
  def build_records
    puts "RECORDS SET: #{@response['RecordsSet']}"
    
    # NOTE: this may need to be reworked a little. look in recordset for nodes that our outside of records...
    @records = []
    unless @response['RecordsSet'].nil?
      if @response['RecordsSet']['Record'].instance_of?(Hash)
        @records.push(EndecaXml::Record.new(@response['RecordsSet']))
      elsif @response['RecordsSet']['Record'].instance_of?(Array)
        @response['RecordsSet']['Record'].each do |record|
          @records.push(EndecaXml::Record.new(record))
        end
      else
        puts "This record is a(n): #{@response['RecordsSet'].class}"
      end
    else
      puts 'There are no records with this response!'
    end
  end
  
  # builds the BREADCRUMBS hash
  # TODO: one final pass on this to make sure its awesome (do i need the has for each key/values?) readdress how the filtercrumbs are handles and see if it is the best way
  def build_breadcrumbs
    @breadcrumbs  = []
    @filtercrumbs = []
    
    # puts "BREADCRUMBS: #{@response['Breadcrumbs'}"
    breadcrumbs = @response['Breadcrumbs']
    unless breadcrumbs.nil?
      
      # puts "BREADS: #{@response['Breadcrumbs']['Breads']}"
      breads = @response['Breadcrumbs']['Breads']
      
      breads.each do |bread|
        bread.each do |key, value|
          @filtercrumbs.push(value)
        end
      end
      
      if breads.instance_of?(Hash)
        # puts "HASH 1: #{breads}"
        if breads.instance_of?(Hash)
          # puts "HASH 2: #{breads}"
          if breads['Bread'].instance_of?(Hash)
            # puts "HASH 2: #{breads['Bread']}"
            breads['Bread'].each do |key, value|
              # puts "#{key} :: #{value}"
              @breadcrumbs.push(EndecaXml::Crumb.new(breads['Bread']))
            end
          elsif breads['Bread'].instance_of?(Array)
            # puts "ARRAY 2: #{breads['Bread']}"
            breads['Bread'].each do |crumb|
              # puts "CRUMB 2: #{crumb}"
              @breadcrumbs.push(EndecaXml::Crumb.new(crumb))
            end
          end
          @filtercrumbs.push(breads['Bread'])
        elsif bread.instance_of?(Array)
          # puts "ARRAY 1: #{breads}"
          breads.each do |crumb|
            # puts "CRUMB: #{crumb}"
            @breadcrumbs.push(EndecaXml::Crumb.new(crumb))
          end
        end
      elsif breads.instance_of?(Array)
        # puts "ARRAY 1: #{breads}"
        breads.each do |bread|
          # puts "BREAD: #{bread}"
          if bread.instance_of?(Hash)
            # puts "HASH 1: #{bread}"
            if bread['Bread'].instance_of?(Hash)
              # puts "HASH 2: #{bread}"
              bread['Bread'].each do |key, value|
                # puts "#{key} :: #{value}"
                @breadcrumbs.push(EndecaXml::Crumb.new(bread['Bread']))
              end
            elsif bread['Bread'].instance_of?(Array)
              # puts "ARRAY 2: #{bread}"
              bread['Bread'].each do |crumb|
                # puts "CRUMB 2: #{crumb}"
                @breadcrumbs.push(EndecaXml::Crumb.new(crumb))
              end
            end
          elsif bread.instance_of?(Array)
            # puts "ARRAY 3: #{bread}"
            bread['Bread'].each do |crumb|
              # puts "CRUMB 3: #{crumb}"
              @breadcrumbs.push(EndecaXml::Crumb.new(crumb))
            end
          end
        end
      end
    else  
      puts 'There are no breadcrumbs with this response!'
    end
  end
  
  # builds the DIMENSIONS hash
  # NOTE: do what breadcrumbs is doing in terms of vars
  def build_dimensions
    @dimensions = []
    
    puts "DIMENSIONS: #{@response['Dimensions']}"
    dimensions = @response['Dimensions']
    
    unless @response['Dimensions'].nil?
      
      # puts "DIMENSION: #{@response['Dimensions']['Dimension']}"
      dimension = @response['Dimensions']['Dimension']
      
      if dimension.instance_of?(Hash)
        @dimension = EndecaXml::Dimension.new(dimensions)
        unless dimension['DimensionValues'].nil?
          if dimension['DimensionValues']['DimensionValue'].instance_of?(Hash)
            @dimension.dimension_values.push(EndecaXml::Dimension.new(dimension['DimensionValues']))
          elsif dimension['DimensionValues']['DimensionValue'].instance_of?(Array)
            dimension['DimensionValues']['DimensionValue'].each do |dimension_value|
              @dimension.dimension_values.push(EndecaXml::Dimension.new(dimension_value))
            end
          else
            puts "This dimension value is a(n): #{dimension['DimensionValues']['DimensionValue'].class}"
          end
          @dimensions.push(@dimension)
        else
          puts "There are no dimension values on this dimension!"
        end
      elsif dimension.instance_of?(Array)
        dimension.each do |dimension|
          @dimension = EndecaXml::Dimension.new(dimension)
          unless dimension['DimensionValues'].nil?
            if dimension['DimensionValues']['DimensionValue'].instance_of?(Hash)
              @dimension.dimension_values.push(EndecaXml::Dimension.new(dimension['DimensionValues']))
            elsif dimension['DimensionValues']['DimensionValue'].instance_of?(Array)
              dimension['DimensionValues']['DimensionValue'].each do |dimension_value|
                @dimension.dimension_values.push(EndecaXml::Dimension.new(dimension_value))
              end
            else
              puts "This dimension value is a(n): #{dimension['DimensionValues']['DimensionValue'].class}"
            end
            @dimensions.push(@dimension)
          else
            puts 'There are no dimension values on this dimension!'
          end
        end
      else
        puts "This dimension is a(n): #{dimensions.class}"
      end
    else
      puts 'There are no dimensions with this response!'
    end
  end
  
  # builds the BUSINESS RULES hash
  def build_business_rules
    puts "BUSINESS RULES: #{@response['BusinessRulesResult']}"
    
    # NOTE: needs to be looked at again. look at where the array is being pushed
    @business_rules = []
    unless @response['BusinessRulesResult'].nil?
      if @response['BusinessRulesResult']['BusinessRules'].instance_of?(Hash)
        @business_rule = EndecaXml::Rule.new(@response['BusinessRulesResult']['BusinessRules'])
        @response['BusinessRulesResult']['BusinessRules'].each do |key, value|
          @business_rule.properties_array.push(EndecaXml::Rule.new(value)) if key == 'properties'
          if key == 'RecordSet'
            @business_rule.records.push(EndecaXml::Record.new(value['Record'])) unless value.nil?
          end
        end
      elsif @response['BusinessRulesResult']['BusinessRules'].instance_of?(Array)
        @response['BusinessRulesResult']['BusinessRules']['BusinessRule'].each do |rule|
          @business_rule = EndecaXml::Rule.new(rule)
          rule.each do |key, value|
            @business_rule.properties_array.push(EndecaXml::Rule.new(value)) if key == 'properties'
            if key == 'RecordSet'
              @business_rule.records.push(EndecaXml::Record.new(value['Record'])) unless value.nil?
            end
          end
        end
      else
        puts "This busniess rule is a(n): #{@response['RecordsSet'].class}"
      end
      @business_rules.push(@business_rule)
    else
      puts 'There are no business rules with this response!'
    end
  end
  
  # builds the SEARCH REPORTS hash
  def build_search_reports
    @search_reports = []
    
    # puts "APPLIED FILTERS: #{@response['AppliedFilters']}"
    applied_filters = @response['AppliedFilters']
    unless applied_filters.nil?
      
      # puts "SEARCH REPORTS: #{@response['AppliedFilters']['SearchReports']}"
      search_reports = @response['AppliedFilters']['SearchReports']
      unless search_reports.nil?
        #do stuff
      else
        puts 'There are no search reports with this response!'
      end
      
    else
      puts 'There were not applied filters with this response!'
    end
  end
  
  # builds the SELECTED DIMENSION VALUE IDS hash
  def build_selected_dimension_value_ids
    @selected_dimension_value_ids = []
    
    # puts "SELECTED DIMENSION VALUE IDS: #{@response['AppliedFilters']['SelectedDimensionValueIds']}"
    selected_dimension_value_ids = @response['AppliedFilters']['SelectedDimensionValueIds']
    unless selected_dimension_value_ids.nil?
      
      if selected_dimension_value_ids.instance_of?(Hash)
        selected_dimension_value_id = EndecaXml::DimensionValueId.new(selected_dimension_value_ids)
      elsif selected_dimension_value_ids.instance_of?(Array)
        selected_dimension_value_ids.each do |key, value|
          selected_dimension_value_id = EndecaXml::DimensionValueId.new(value)
        end
      end
      
      @selected_dimension_value_ids.push(selected_dimension_value_id)
      
    else
      puts "There are no selected dimension value ids with this response!"
    end
  end
  
end
