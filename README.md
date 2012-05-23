# Calendrier

##DESCRIPTION

A simple helper for creating an HTML calendar. 
It allows to display events.

##SYNOPSIS:

    # Display month
    <%= calendrier(:year => 2012, :month => 5, :day => 25, :start_on_monday => true) do |current_time| %>
    <%= display_events(@events_by_date, current_time, :month) %>
    <%= link_to("Ajouter le #{current_time.day}", new_meeting_path) %>
    <% end %>

    # Display week
    <%= calendrier(:year => 2012, :month => 5, :day => 25, :start_on_monday => true, :display => :week) do |current_time| %>
    <%= display_events(@events_by_date, current_time, :week) %>
    <%= link_to("Ajouter le #{current_time.day} à #{current_time.hour}h", new_meeting_path) %>
    <% end %>


Events could be a mix of many different objects, but each of them should `respond_to?` one of the following method sets :

  * `year`, `month`, `day`
  * `begin_date`, `end_date`

## INSTALLATION

Add this line to your application's Gemfile:

    gem 'calendrier'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install calendrier


##AUTHORS

Romain Castel

##USAGE

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
