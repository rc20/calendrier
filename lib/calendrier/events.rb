module Calendrier 
  module Events
    #return the beginning of event in timestamp
    def self.get_event_stamp(event, options = {})
      #tests events
      if event.respond_to?(:year) && event.respond_to?(:month) && event.respond_to?(:day)
        #affect the timestamp
        ret = Time.utc(event[:year], event[:month], event[:day]).to_i
      #otherwise event include date of beginning and date of end
      elsif event.respond_to?(:begin_date) && event.respond_to?(:end_date)
        #if end_date
        if options[:end_date]
          #affect end_date
          ret = event[:end_date]
        else
          #affect begin_date
          ret = event[:begin_date]
        end
      end
      #return result
      return ret
    end

    #display event
    def self.display_event?(event, display_time, display)
      #condition on display events
      if event.respond_to?(:year) && event.respond_to?(:month) && event.respond_to?(:day)
        #if choose the week or month, we compare year, month and day
        if display == :week || display == :month
          ok = true if event.year == display_time.year && event.month == display_time.month && event.day == display_time.day
        end
      end

      #if event has an determine duree
      if event.respond_to?(:begin_date) && event.respond_to?(:end_date)
        #if choose the week
        if display == :week
          #current date in cell begin
          cell_begin = display_time.to_i
          #add an hour
          cell_end = cell_begin + 3600
        #if choose month
        else
          #timestamp of 'one_day' à 00h00
          cell_begin = display_time.to_i 
          #calculate day after
          cell_end = cell_begin + 3600 * 24   
        end

        #if event begin before begin interval
  	    if event.begin_date.to_i <= cell_begin
  	      #if event end in interval
  	      if event.end_date.to_i <= cell_end
  	        #is event end after begin interval
  	        if event.end_date.to_i > cell_begin           
  	          ok = true
  	        end
  	      else
  	        #if event ending after the ending of interval
  	        ok = true
  	      end
  	    else
  	      #if the event ending after the beginning of the interval
  	      if event.end_date.to_i <= cell_end
  	        #if the event ending in interval
  	        ok = true
  	      else
  	        #if event ending after the ending of interval
  	        if event.begin_date.to_i < cell_end
  	          ok = true
  	        end
  	      end
  	    end
  	    #result
        return ok
      end
    end

  end
end