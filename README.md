# EndecaOnDemand

[![Build Status](https://secure.travis-ci.org/sdomino/endeca_on_demand.png)](http://travis-ci.org/sdomino/endeca_on_demand)

[![Dependency Status](https://gemnasium.com/sdomino/endeca_on_demand.png?travis)](https://gemnasium.com/sdomino/endeca_on_demand)

This Endeca On-Demand Web API gem will take a query-string and construct an XML query and send it to an hosted Endeca On-Demand Cluster. It will then parse the response and expose an API for using the response data.

## Features
* Provides an easy way for you to use the Thanx Media, Endeca On-Demand Web API
* Builds an XML query from a query-string, formatted for the Endeca On-Demand Service
* Handles the Endeca On-Demand response XML and exposes methods to use response data

NOTE: Due to the implementation specific requirements used while creating this gem, I know there are missing features. If you find issues, or can provide me with any specifics about your implementation, I can add more support.

### What I would like to see:

* Information reguarding the JSON equivelent of this implementation so I can add JSON support
* Information reguarding filters, to enhance this functionality
* Additional advanced parameters

## Install
### Rails

Add this line to your Gemfile:

```ruby
gem 'endeca_on_demand'
```

Then bundle install:

```bash
bundle install
```

### Non Rails

```ruby
gem install endeca_on_demand
```

## Usage

EndecaOnDemand constructs an XML query to send to a hosted Endeca On-Demand Cluster, via a query string:
NOTE: This is a complete example. Any unneeded option should not be included in the query-string

```html
<a href='www.example.com/example/catalog?search-key=primary&search-term=name&DimensionValueIds=1,2,3,4&sort-key=name&sort-direction=descending&RecordOffset=0&RecordsPerPage=9&AggregationKey=name&UserProfiles=1,2,3,4&filter=between'>FULL ENDECA REQUEST</a>
```

The following is an example of an empty 'options' hash that would then need to be constructed from a query-string:
NOTE: The base options and current category are set manually and not via a query-string

```ruby
options = {
            'add_base'                          => {'RecordsSet' => true, 'Dimensions' => true, 'BusinessRulesResult' => true, 'AppliedFilters' => true},
            'add_keyword_search'                => {},
            'add_dimension_value_id_navigation' => [],
            'add_category_navigation_query'     => "current_category_id",
            'add_sorting'                       => {},
            'add_paging'                        => {},
            'add_advanced_parameters'           => {},
            'add_profiles'                      => [],
            'add_filters'                       => {}
          }
```

The following is what a prepared 'options' hash would look like (using the above example query-string):
NOTE: This is a complete example. It is not necessary to include anything that you don't need, or you may choose to include it and just leave it blank.

```ruby
options = {
            'add_base'                          => {'RecordsSet' => true, 'Dimensions' => true, 'BusinessRulesResult' => true, 'AppliedFilters' => true},
            'add_keyword_search'                => {'searh-key' => 'key', 'search-term' => 'term'},
            'add_dimension_value_id_navigation' => [1, 2, 3, 4],
            'add_category_navigation_query'     => 1,
            'add_sorting'                       => {'sort-key' => 'key', 'sort-direction' => 'Descending'},
            'add_paging'                        => {'RecordOffset' => 0, 'RecordsPerPage' => 9},
            'add_advanced_parameters'           => {'AggregationKey' => 'key'},
            'add_profiles'                      => [1, 2, 3, 4],
            'add_filters'                       => {}
          }
```

Provide the location of your hosted Endeca On-Demand Cluster (this can be set as a variable or passed directly as a parameter)

```ruby
host = 'your/EndecaOnDemand/hosted/cluster'
```

Pass your 'host' and 'options' hash to new EndecaOnDemand

```ruby
@endeca = EndecaOnDemand.new(host, options)
```
  
All of the following have been exposed as part of the API, most of them will also have sub api methods available which will become visible with a .inspect on the object:

```ruby
@endeca.records
@endeca.breadcrumbs
@endeca.filtercrumbs (Filtercrumbs are breadcrumbs that have been tailored for use as left nav filterables)
@endeca.dimensions
@endeca.rules
@endeca.search_reports
@endeca.keyword_redirect
@endeca.selected_dimension_value_ids
```

I also exposed some 'debug'-ish type options to the API so you can see a little of what your request/response looks like if your not getting back the results your expecting

```ruby
@endeca.uri
@endeca.http
@endeca.base
@endeca.query
@endeca.raw_response
@endeca.response
@endeca.error
```

Below is an example of how you could access the response data:

```ruby
@endeca.records.each do |record|
  puts "----- RECORD: #{record.inspect}"
end
```
  
Each object will then have associated instance variables exposed that will allow you directly call any value on that object:

```ruby
@endeca.records.each do |record|
  puts "----- RECORD NAME: #{record.p_name}"
end
```

## F.A.Q

* Q: I'm getting a response error saying something about multiple values for model Category
* A: You are most likely trying to pass a CategoryId (CID) with DimensionValueId(s) (DVID) that don't match. The DVIDs must belong to the category passed as the CID.

## TODO

* Add tests
* Build in support for filters
* I don't have all the possible advanced parameters, so for now it only handles the default 'AggregationKey'
* Search needs some more testing. Currently its only been setup with a basic search, so I'm not aware of what additional parameters might be coming in, and how I may need to handle them
* I would love it if this could server for both XML and JSON (and whatever additional formats they offer)

## CONTACT

Please contact me with any question, bugs, additions, suggestions, etc.

## Copyright
Copyright (c) 2011 Steve Domino. See LICENSE.txt for further details