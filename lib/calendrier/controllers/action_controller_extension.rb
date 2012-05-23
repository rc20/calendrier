module Calendrier 
  module ActionControllerExtension

    #method sort events
    def sort_events(events, display_time = nil)

      #sort events by date
      events_sorted = events.sort { |x,y| Events.get_event_stamp(x) <=> Events.get_event_stamp(y) } unless events.nil?      
      #hash table
      events_by_date = {}
       
      #return all of the elements                 
      events_sorted.each do |event|

        #get date from event (begin, end)
        begin_time = Time.at(Events.get_event_stamp(event)) 
               
        end_time = Time.at(Events.get_event_stamp(event, :end_date => true))
             
        begin_date = Date.new(begin_time.year, begin_time.month, begin_time.day)
        
        end_date = Date.new(end_time.year, end_time.month, end_time.day)
        
        #calulate duration in days, at least one day
        duration_in_days = (end_date - begin_date).to_i + 1
        
        duration_in_days.times do |index|
          #addition to a date
          current_date = begin_date + index               
            #preparation table if year is in window         
            events_by_date[current_date.year.to_s] = {} if events_by_date[current_date.year.to_s].nil?  

            #preparation table if year and month are in window  
            events_by_date[current_date.year.to_s][current_date.month.to_s] = {} if events_by_date[current_date.year.to_s][current_date.month.to_s].nil?  

            #preparation table if year, month and day is in window  
            events_by_date[current_date.year.to_s][current_date.month.to_s][current_date.day.to_s] = [] if events_by_date[current_date.year.to_s][current_date.month.to_s][current_date.day.to_s].nil? 

            #construction table
            events_by_date[current_date.year.to_s][current_date.month.to_s][current_date.day.to_s] << event
        end
      end
      #result final table
      return events_by_date
    end
  end
end