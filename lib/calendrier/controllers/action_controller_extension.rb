module Calendrier 
  module ActionControllerExtension
#    extend Calendrier::Events

    #sort events
    def sort_events(events, display_time = nil)
p "ICI"
      #sort events by date
      events_sorted = events.sort { |x,y| get_event_stamp(x) <=> get_event_stamp(y) } unless events.nil?
p events_sorted
      # sort table date
      events_by_date = []
      events_sorted.each do |event|
p "event"
p event
        # get date from event (begin, end)
        begin_time = Time.at(Events.get_event_stamp(event))        
        end_time = Time.at(Events.get_event_stamp(event, :end_date => true))
             
        begin_date = Date.new(begin_time.year, begin_time.month, begin_time.day)
        end_date = Date.new(end_time.year, end_time.month, end_time.day)
        
        #calulate duration in days
        #at least one day
        duration_in_days = (end_date - begin_date).to_i + 1 
        
        duration_in_days.times do |index|
          # !!! ADDITION A UNE DATE --> +n jours
          current_date = begin_date + index

          #if current_date.year == display_time.year && current_date.month == display_time.month
            #preparation table if date is in window
p "events_by_date1 #{current_date.year}"
p events_by_date
            events_by_date[current_date.year] = [] if events_by_date[current_date.year].nil?  
p "events_by_date2"
p events_by_date
            events_by_date[current_date.year][current_date.month] = [] if events_by_date[current_date.year][current_date.month].nil?  
p "events_by_date3"
p events_by_date
            events_by_date[current_date.year][current_date.month][current_date.day] = [] if events_by_date[current_date.year][current_date.month][current_date.day].nil? 
p "events_by_date4"
p events_by_date
            #construction table
            events_by_date[current_date.year][current_date.month][current_date.day] << event
p "events_by_date5"
p events_by_date
          #end
        end
      end
      #result table
      return events_by_date
    end

  end
end