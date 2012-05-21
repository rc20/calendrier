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

    #time-lag of days
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
    def display_event?(event, display_time, display)
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

    def display_event(event)
	    #concatenation title and event
	    title = link_to "#{event.title}", event
	    #return title of the event in a list
	    event_content = content_tag(:li, title, :class => event.category)
	    #return content of each cell
	    return event_content
    end

    #sort events
    def sort_events(events, display_time)
      #sort events by date
      events_sorted = events.sort { |x,y| get_event_stamp(x) <=> get_event_stamp(y) } unless events.nil?
      # sort table date
      events_by_date = []
      events_sorted.each do |event|
        # get date from event (begin, end)
        begin_time = Time.at(get_event_stamp(event))         
        end_time = Time.at(get_event_stamp(event, :end_date => true))
        
        # verification de l'existance du tableau pour les dates de l'evenement
        # verification des jours
        
        begin_date = Date.new(begin_time.year, begin_time.month, begin_time.day)
        end_date = Date.new(end_time.year, end_time.month, end_time.day)
        
        #calulate duration in days
        #at leaat one day
        duration_in_days = (end_date - begin_date).to_i + 1 
        
        duration_in_days.times do |index|
          # !!! ADDITION A UNE DATE --> +n jours
          current_date = begin_date + index

          if current_date.year == display_time.year && current_date.month == display_time.month
            # préparation du tableau si la date est dans la fenetre affichee
            events_by_date[current_date.year] = [] if events_by_date[current_date.year].nil?  
            events_by_date[current_date.year][current_date.month] = [] if events_by_date[current_date.year][current_date.month].nil?  
            events_by_date[current_date.year][current_date.month][current_date.day] = [] if events_by_date[current_date.year][current_date.month][current_date.day].nil? 
            #on remplit le tableau
            events_by_date[current_date.year][current_date.month][current_date.day] << event
          end
        end
      end
      #result
      return events_by_date
    end
    
    #display events
    def display_events(events, display_time, display)
      current_date = Date.new(display_time.year, display_time.month, display_time.day)
     
      #sort events
      events_by_date = sort_events(events, current_date)
      
      #initialisation variable cell_content and cell_sub_content
      cell_content = nil
      cell_sub_content = nil
   
      #test whether or not the presence of events
      if events_by_date[display_time.year] && events_by_date[display_time.year][display_time.month] && events_by_date[display_time.year][display_time.month][display_time.day]
        events_by_date[display_time.year][display_time.month][display_time.day].each do |event|               
					#display
					ok = display_event?(event, display_time, display)
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
      end
 
      #create content cell
      cell_content = content_tag(:ul, cell_sub_content) unless cell_sub_content.nil?
      
      #result
      return cell_content
      
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

      #choose to begin by monday
      start_on_monday = options[:start_on_monday]

      #first day of month
      first_day_of_month = Time.utc(year, month, 1).wday
      #taking into account the lag
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

      #object date
      current = Date.new(year, month, day)

      #display days of week
      #copy in memmory with dup
      days_name = t('date.day_names').dup

      #if it's monday, time-lag
      if start_on_monday
        1.times do
          days_name.push(days_name.shift)
        end
      end

      #sort events
      events_by_date = sort_events(events, current)

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
          #choose Monday
          day_shift = LUNDI
        else
          #choose Sunday
          day_shift = DIMANCHE
        end
        
        #first day of week wih time-lag
        first_day_of_week = get_day(current, day_shift)

        #generate header
        table_head = content_tag(:tr, content_tag('th', 'Horaires') + days_name.enum_for(:each_with_index).collect { |day_name, index| content_tag('th', "#{day_name} #{(first_day_of_week + index).to_s}" ) }.join.html_safe )

        #month_content = content_tag(:thead, content_tag(:tr, content_tag('th', 'horaires') + days_name.collect { |h| content_tag('th', h ) }.join.html_safe ))
        # %w(a b c).enum_for(:each_with_index).collect { |o, i| "#{i}: #{o}" }
        #returns: ["0: a", "1: b", "2: c"]
          
        #initialisation
        table_content = nil

        #de 0 to 24h excludes
        (0...HOURS_IN_DAY).each do |hour_index|
          #each line of table      
          sub_content = content_tag(:tr, nil) do
            #affect each cell of table
            hour_content = content_tag(:td, hour_index)
            #return 7 times the day
            DAYS_IN_WEEK.times do |index|  
            
    					#current day
    					this_day = (first_day_of_week + index)
    					#hours calendar
    					time_of_day = Time.utc(this_day.year, this_day.month, this_day.day, hour_index)
              #appelle de la méthode
              cell_content = display_events(events, time_of_day, display)                               
              #if time_of_day is not null
              unless time_of_day.nil?
                #capture time_of_day and block
            	  bloc = capture(time_of_day, &block) if block_given?
            	  #affectation if cell_content is not null
          	    cell_content << bloc unless cell_content.nil?         			        			   
          	    cell_content = bloc if cell_content.nil?         			        			   
              end
              #affectation cell_content in table
              hour_content << content_tag(:td, cell_content)
            end
            #result
            hour_content
          end
          #subcontent is not null we add dans sub_content
          table_content << sub_content unless table_content.nil?
          #suba_content is empty, we affect subacontent
          table_content = sub_content if table_content.nil?
          #result
          table_content
        end
        
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
            #beginning of month
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
        
        #display calendar
        table_content = nil
        #while length is positive
        while days_arr.length > 0
          #initiate
          week_content =  nil
          #indentation in slice to 7 (DAYS_IN_WEEK) jours
          one_week = days_arr.slice!(0, DAYS_IN_WEEK)
          #preparation td in variable 
          one_week.each do |one_day|
            #test if day is an integer
            if one_day.is_a?(Integer)
              time_of_day = Time.new(year, month, one_day)
              cell_content = display_events(events, time_of_day, display) 
            end

            #if time_of_day is not null
            unless time_of_day.nil?
              #capture time_of_day and block
          	  bloc = capture(time_of_day, &block) if block_given?
          	  #affectation if cell_content is not null
        	    cell_content << bloc unless cell_content.nil?         			        			   
        	    cell_content = bloc if cell_content.nil?         			        			   
            end
		 	                    
            #affect content                      
            sub_content = content_tag(:td, content_tag(:span, one_day) + cell_content)

            #test week_content
            if week_content.nil?
              week_content = sub_content
            else
              week_content << sub_content
            end
          end
          
          #put all the 'td' in 'tr'
          sub_content = content_tag(:tr, week_content)
          #test if month_content empty
          if table_content.nil?
            table_content = sub_content
          else
            table_content << sub_content
          end
          #return content of month
          table_content
        end
      end

      #
      ##
      ###
      #### IF MONTH / fin ####

      #### DISPLAY / debut ####
      ###
      ##
      #
          
      content_tag(:div, nil, :class => 'calendar') do  
        #test if add a 0 or not by month
        month_two_digit = (month <= 9 ? "#{0}#{month}" : month.to_s)
        #head each table
        titre = "#{year} / #{month_two_digit}"
        #affectation de la balise span
        cal = content_tag(:span, titre)
        cal << content_tag(:table, nil) do
          #display header
          month_content = content_tag(:thead, table_head)
          #display content
          month_content << content_tag(:tbody, table_content)
        end
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