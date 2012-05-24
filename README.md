# Calendrier

##DESCRIPTION

A simple helper for creating an HTML calendar. 
It allows to display events.

##SYNOPSIS:

    # Add to view
    # app/views/home/index.html.erb

    # Display month
    <%= calendrier(:year => 2012, :month => 5, :day => 25, :start_on_monday => true) do |current_time| %>
      <%= display_events(@events_by_date, current_time, :month) %>
      # Add an event into current month
      <%= link_to("Ajouter le #{current_time.day}", new_meeting_path) %>
    <% end %>

    # Display week
    <%= calendrier(:year => 2012, :month => 5, :day => 25, :start_on_monday => true, :display => :week) do |current_time| %>
      <%= display_events(@events_by_date, current_time, :week) %>
      # Add an event into current week
      <%= link_to("Ajouter le #{current_time.day} à #{current_time.hour}h", new_meeting_path) %>
    <% end %>

    # Add to controller
    # app/controllers/home_controller.rb
    
    # Sort events by date
    @events_by_date = sort_events(@events)
    
    # Affect all events
    @events = Meeting.all
    
    # For example :
    # db/migrate/seeds.rb
    
    # Create event for specific period
    Meeting.create(:title => 'formation', :begin_date => Time.new(2012,5,21,14,10), :end_date => Time.new(2012,5,24,15,50), :meeting_type => 'formation')
    
    
Events could be a mix of many different objects, but each of them should `respond_to?` one of the following method sets :

  * `year`, `month`, `day`
  * `begin_date`, `end_date`

##INSTALLATION

Add this line to your application's Gemfile:

    gem 'calendrier'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install calendrier


##AUTHORS

Romain Castel <br />
Thomas Kienlen

##USAGE

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
