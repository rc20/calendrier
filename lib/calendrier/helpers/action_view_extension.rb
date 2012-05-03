module Calendrier 
  module ActionViewExtension
  
    #numbers of days in the week
    DAYS_IN_WEEK = 7
    #numbers of hours in day
    HOURS_IN_DAY = 24
    # week days
    DIMANCHE = 0
    LUNDI = 1

    #return the beginning of event in timestamp
    def get_event_stamp(event, options = {})
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

    #decalage of days
    def shift_week_days(wday, index)
      wday -= index
      #add + 7 time-lag
      wday += DAYS_IN_WEEK if wday < 0
      #return time-lag
      return wday
    end

    #recover day
    def get_day(current, wday)
      #time-lag if end of month
      days_shift = (current.wday - wday)
      #current day
      current - days_shift
    end

    #display event
    def display_event?(event, current_date, display)
      #condition on display events
      if event.respond_to?(:year) && event.respond_to?(:month) && event.respond_to?(:day)
        #if choose the week, we compare year, month and day
        if display == :week
          ok = true if event.year == current_date.year && event.month == current_date.month && event.day == current_date.day
        else
          #else if month
          ok = true if event.year == current_date.year && event.month == current_date.month && event.day == current_date.day
        end
      end

      #test date begin and end date
      #test if event has an determine duree
      if event.respond_to?(:begin_date) && event.respond_to?(:end_date)
        #if choose the week
        if display == :week
          #affect the current date in cell begin
          cell_begin = current_date.to_i
          #add an hour
          cell_end = cell_begin + 3600
        else
          # month
          #timestamp of 'one_day' à 00h00
          cell_begin = current_date.to_i 
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
  	    #return result
        return ok
      end
    end

    def display_event(event)
	    #concatenation title and event
	    title = link_to "#{event.title}", event
	    #return title of the event in a list
	    event_content = content_tag(:li, title, :class => event.category)
	    #return content of each cell
	    return event_content
    end


    #display calendar
    def calendrier(events = nil, options = {}, &block)

      #### COMMUN / debut ####
      ###
      ##
      #

      #option year
      year = options[:year] || Time.now.year

      #option month
      month = options[:month] || Time.now.month

      #option day
      day = options[:day] || Time.now.day

      #option display
      display = options[:display] || :month

      #if choose to begin by monday
      start_on_monday = options[:start_on_monday]

      #first day of month
      first_day_of_month = Time.utc(year, month, 1).wday
      #time-lag if begin by Monday
      first_day_of_month = shift_week_days(first_day_of_month, 1) if start_on_monday

      #numbers days in month
      days_in_month = Time.utc(year, month, 1).end_of_month.day

      #numbers week in month
      days = (days_in_month + first_day_of_month)
      weeks_in_month = (days / DAYS_IN_WEEK) + (days%DAYS_IN_WEEK != 0 ? 1 : 0)

      #create table include calendar
      days_arr = []

      #initialise counter of journey
      day_counter = 0

      #instanciate object current
      current = Date.new(year, month, day)

      #display days of week
      #copy in memmory with dup
      days_name = t('date.day_names').dup

      #if it's monday , time-lag
      if start_on_monday
        1.times do
          days_name.push(days_name.shift)
        end
      end

      #
      ##
      ###
      #### COMMUN / fin ####


      #if choose the week
      if display == :week


        #### IF WEEK / debut ####
        ###
        ##
        #

        #options start week
        if start_on_monday
          #if choose Monday
          day_shift = LUNDI
        else
          #if choose Sunday
          day_shift = DIMANCHE
        end
        #affectation first day of week
        first_day_of_week = get_day(current, day_shift)

        #generate header
        table_head = content_tag(:tr, content_tag('th', 'Horaires') + days_name.enum_for(:each_with_index).collect { |day_name, index| content_tag('th', "#{day_name} #{(first_day_of_week + index).to_s}" ) }.join.html_safe )

        #month_content = content_tag(:thead, content_tag(:tr, content_tag('th', 'horaires') + days_name.collect { |h| content_tag('th', h ) }.join.html_safe ))
        # %w(a b c).enum_for(:each_with_index).collect { |o, i| "#{i}: #{o}" }
        #returns: ["0: a", "1: b", "2: c"]
          
          #initialisation
          suba_content = nil

          #preparation sorted events for each journey
          events_sorted = events.sort { |x,y| get_event_stamp(x) <=> get_event_stamp(y) } unless events.nil?
          #de 0 to 24h excludes
          (0...HOURS_IN_DAY).each do |hour_index|
            #affect each line of table      
            sub_content = content_tag(:tr, nil) do
              #affect each cell of table
              hour_content = content_tag(:td, hour_index)
              #return 7 times the day
              DAYS_IN_WEEK.times do |index|
                #initiate variable
                cell_sub_content = nil
                events_sorted.each do |event|
        					#current day
        					this_day = (first_day_of_week + index)
        					#instanciate
        					time_of_day = Time.new(this_day.year, this_day.month, this_day.day, hour_index)
        					#display
        					ok = display_event?(event, time_of_day, display)
        					#if display event
        					if ok
                    event_content = display_event(event)
        					  if cell_sub_content.nil?
        					    cell_sub_content = event_content
        					  else
        					    cell_sub_content << event_content
        					  end
        					end
                end
                #create list
                cell_content = content_tag(:ul, cell_sub_content) unless cell_sub_content.nil?
                #instanciate
                time_of_day = Time.new(year, month, day)
                #if day if empty
                unless time_of_day.nil?
                  #capture day and block
        		  	  bloc = capture(time_of_day, &block) if block_given?
        		  	  #if cell is not null we addd cell_content 
        			    cell_content << bloc unless cell_content.nil?  
        			    #if cell_content is empty we affect bloc       			        			   
        			    cell_content = bloc if cell_content.nil?         			        			   
                end
                #affectation cell_content in table
                hour_content << content_tag(:td, cell_content)
              end
              #return cell
              hour_content
            end
            #if subcontent is not null we add dans sub_content
            suba_content << sub_content unless suba_content.nil?
            #if suba_content is empty, we affect subacontent
            suba_content = sub_content if suba_content.nil?
            #return
            suba_content
        end
        #display content
        table_content = content_tag(:div, suba_content)
        
        #
        ##
        ###
        #### IF WEEK / fin ####

      else
        #else it's month

        #### IF MONTH / debut ####
        ###
        ##
        #

        #generate header
        table_head = content_tag(:tr, days_name.collect { |h| content_tag('th',h) }.join.html_safe )
        #iteration on each week in month
        weeks_in_month.times do |week_index|
          #iteration on each journey in week
          (0...DAYS_IN_WEEK).each do |day_index|
            #if beginning of month
            if day_counter == 0
              #test beginning of calendar, which begin with the good day in the week
              if day_index != first_day_of_month
                #while we haven't the good day of the week we add x
                days_arr << 'x'
              else
                #we add 1 in the table
                days_arr << 1
                #we increment counter
                day_counter += 1
              end
            else
              #if it's the good day
              day_counter +=1
              #if we are always in the calendar
              if day_counter <= days_in_month
                #we add the number of day in the table
                 days_arr << day_counter
              else
                #add x at the end of table
                days_arr << 'x'
              end
            end
          end
        end

        #preparation events for each journey
        events_sorted = events.sort { |x,y| get_event_stamp(x) <=> get_event_stamp(y) } unless events.nil?
        #days table
        events_by_days = []
        #empty table
        events_sorted = [] if events_sorted.nil?
        events_sorted.each do |event|
          #test if courant time is between "begin_stamp" and "end_stamp"
          #date beginning
          begin_date = Time.at(get_event_stamp(event))
          #date end
          end_date = Time.at(get_event_stamp(event, :end_date => true))
          #test year month and day
          if (begin_date.year == end_date.year && begin_date.month == end_date.month && begin_date.day == end_date.day)
            #event of journey
            events_by_days[begin_date.day] = [] if events_by_days[begin_date.day].nil?
            events_by_days[begin_date.day] << event
          else
            #event that during in time
            (begin_date.day..end_date.day).each do |event_day|
              events_by_days[event_day] = [] if events_by_days[event_day].nil?
              events_by_days[event_day] << event
            end
          end
        end
        
        #display calendar
        month_content = nil
        #while length is positive
        while days_arr.length > 0
          #initiate
          week_content =  nil
          #indentation in slice to 7 (DAYS_IN_WEEK) jours
          one_week = days_arr.slice!(0, DAYS_IN_WEEK)
          #preparation td in variable
          one_week.each do |one_day|
            #content of a cell
            cell_sub_content = nil
            #test if day is an integer
            if one_day.is_a?(Integer)
              time_of_day = Time.new(year, month, one_day)
            end
            #display list
            cell_content = content_tag(:ul, nil) do
              #test day is an integer
              if one_day.is_a?(Integer) && !events_by_days[one_day].nil?
                # add 'li' only
                content_tag(:li, nil) do                 
                  events_by_days[one_day].each do |event|
                    #test if one_day in integer
                    if one_day.is_a?(Integer)
                      ok = display_event?(event, time_of_day, display)
                    end
                    #if display_event is ok
                    if ok
                    	event_content = display_event(event)
                      #if is empty
            					if cell_sub_content.nil?
            					 	cell_sub_content = event_content
            					else
            					    cell_sub_content << event_content
            					end
                    end
                  end
                end
              end
      			  #return
      			  cell_sub_content
      		 	end           
            #if time_of_day is not null
            unless time_of_day.nil?
              #capture time_of_day and block
    		  	  bloc = capture(time_of_day, &block) if block_given?
    		  	  #affectation if cell_content is not null
    			    cell_content << bloc unless cell_content.nil?         			        			   
    			    cell_content = bloc if cell_content.nil?         			        			   
            end
            #affectation content_tag                       
            sub_content = content_tag(:td, content_tag(:span, one_day) + cell_content)
          #test if week_content is null
          if week_content.nil?
            week_content = sub_content
          else
            week_content << sub_content
          end
        end
          #put all the 'td' in 'tr'
          sub_content = content_tag(:tr, week_content)
          #test if month_content empty
          if month_content.nil?
            month_content = sub_content
          else
            month_content << sub_content
          end
          #return content of month
          month_content
        end
        #display content
        table_content = content_tag(:div, month_content)
    end

        #
        ##
        ###
        #### IF MONTH / fin ####

        #### DISPLAY / debut ####
        ###
        ##
        #

        #display calendar
        content_tag(:table, nil) do
          #display header
          month_content = content_tag(:thead, table_head)
          #display content
          month_content << content_tag(:tbody, table_content)
        end

        #
        ##
        ###
        #### DISPLAY / fin ####

    #end calendar
    end
  #end module
  end
#end module
end