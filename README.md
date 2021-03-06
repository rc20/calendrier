# Calendrier

##DESCRIPTION

A simple helper for creating an HTML calendar. 
It allows to display events.

##SYNOPSIS:

A method to sort out an array of events is availlable in your controllers. 
To use that method, Events could be a mix of many different objects, but each of them should `respond_to?` one of the following method sets :

  * `year`, `month`, `day`
  * `begin_date`, `end_date`

In your controller :

    # app/controllers/home_controller.rb
    
    # Affect all events
    @events = Meeting.all
    @events << Appointment.all
    
    # Prepare Hash of events sorted by date, for later use inside cells.
    @events_by_date = sort_events(@events)
    


A method is provided to display events, it takes as first argument a Hash like this :

    events_by_date => {"2012"=>{"5"=>{"21"=>[#<Event>, #<Event>]}}}
    
Such Hash is returned by `sort_events` method.

In your view :

    # app/views/home/index.html.erb

    # Display monthly calendar
    <%= calendrier(:year => 2012, :month => 5, :day => 25, :start_on_monday => true) do |current_time| %>
      # you may use the following method to display events of the current day 
      <%= display_events(@events_by_date, current_time, :month) %>
      # For example, add an event into current day cell
      <%= link_to("Add meeting at #{current_time.day}/#{current_time.month}", new_meeting_path) %>
    <% end %>

    # Display weekly calendar
    <%= calendrier(:year => 2012, :month => 5, :day => 25, :start_on_monday => true, :display => :week) do |current_time| %>
      <%= display_events(@events_by_date, current_time, :week) %>
      <%= link_to("Add meeting at #{current_time.hour}h", new_meeting_path) %>
    <% end %>
    

##INSTALLATION

Add this line to your application's Gemfile:

    gem 'calendrier'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install calendrier


##AUTHORS

Romain Castel

Thomas Kienlen

##USAGE

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
