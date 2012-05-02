# Freya

## [The Goddess](http://en.wikipedia.org/wiki/Freyja)

![Freyja](http://4.bp.blogspot.com/_-MH9cjER6vo/SV6C0QmK8iI/AAAAAAAAACw/J9ltwhp6WNg/s1600-R/freyja.gif)

In Norse mythology, Freyja (Old Norse the "Lady") is a goddess associated with love, beauty, fertility, gold, sei&eth;r, war, and death.


## The Gem

* Returns Ruby, or JSON objects
* Handles multiple slave Solr instances
* Degrades Solr cleanly
* Configurable request method

## Usage

This tries to adhere to the [RSolr](https://github.com/mwmitchell/rsolr) and
[RSolr-ext](https://github.com/mwmitchell/rsolr-ext) APIs.

### Configuration

Freya currently is configured using a simple hash.

#### Default Configuration Options

    { 
        "master" => 
            [
                { 
                    "raise_exceptions" => true,
                    "timeout" => 10, 
                    "port" => 33900, 
                    "request_method" => :post, 
                    "host" => "localhost",
                    "response_format" => :ruby
                }
            ]
    }


#### Setups

##### Single Server

    @config = {
        { 
            "master" => 
                [
                    { 
                        "raise_exceptions" => true, 
                        "timeout" => 60, 
                        "port" => 33900, 
                        "request_method" => :post, 
                        "host" => "localhost"
                    }
                ]
        }
        
    }
  
    client = Freya::Client.new(@config)
      
    client.master   #=> #<Freya::Connection: ... >

##### Multi Server

    @config = {
        { 
            "master" => 
                [
                    { 
                        "raise_exceptions" => true, 
                        "timeout" => 60, 
                        "port" => 33900, 
                        "request_method" => :post, 
                        "host"=>"localhost"
                    }
                ],
                
            "slave" => 
                [
                    { 
                        "raise_exceptions" => true, 
                        "timeout" => 60, 
                        "port" => 33901, 
                        "request_method" => :post, 
                        "host"=>"localhost"
                    },
                    { 
                        "raise_exceptions" => true, 
                        "timeout" => 60, 
                        "port" => 33902, 
                        "request_method" => :post, 
                        "host"=>"localhost"
                    }
                    
                ]

        }
    
    }

    client = Freya::Client.new(@config)

    client.master   #=> #<Freya::Connection: ... >
    client.slave    #=> #<Freya::Connection: ... >

## Contributing to Freya
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

See LICENSE.txt for details.

