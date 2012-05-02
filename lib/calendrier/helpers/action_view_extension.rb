module Calendrier 
  module ActionViewExtension
  
    #numbers of days in the week
    DAYS_IN_WEEK = 7
    #numbers of hours in day
    HOURS_IN_DAY = 24
    # week days
    DIMANCHE = 0
    LUNDI = 1

    # return the beginning of event in timestamp
    def get_event_stamp(event, options = {})
      #tests events
      if event.respond_to?(:year) && event.respond_to?(:month) && event.respond_to?(:day)
        #affect the timestamp
        ret = Time.utc(event[:year], event[:month], event[:day]).to_i
      #otherwise event include date of beginning and date of end
      elsif event.respond_to?(:begin_date) && event.respond_to?(:end_date)
        if options[:end_date]
          ret = event[:end_date]
        else
          ret = event[:begin_date]
        end
      end
      #return the result
      return ret
    end

    #decalage
    def shift_week_days(wday, index)
      wday -= index
      wday += DAYS_IN_WEEK if wday < 0
      return wday
    end

    #récupère jour
    def get_day(current, wday)
      #decalage si on arrive en fin de mois
      days_shift = (current.wday - wday)
      #jour courant
      current - days_shift
    end


    #test display event
    def display_event?(event, current_date, display)
      #condition on display events
      if event.respond_to?(:year) && event.respond_to?(:month) && event.respond_to?(:day)
        #si on choisit la semaine
        if display == :week
          #week
          ok = true if event.year == current_date.year && event.month == current_date.month && event.day == current_date.day
        else
          #month
          ok = true if event.year == current_date.year && event.month == current_date.month && event.day == current_date.day
        end
      end

      #test date de début et date de fin
      if event.respond_to?(:begin_date) && event.respond_to?(:end_date)
        #si on choisit la semaine
        if display == :week
          # week
          #cell_begin = Time.utc(current_date.year, current_date.month, current_date.day, current_date.hour).to_i
          cell_begin = current_date.to_i
          cell_end = cell_begin + 3600
        else
          # month
          #timestamp du jour 'one_day' à 00h00
          cell_begin = current_date.to_i # de minuit
          #a minuit (jour d'apres)
          cell_end = cell_begin + 3600 * 24   
        end

  	    if event.begin_date.to_i <= cell_begin
  	      #si l'événement commence avant le debut de l'interval, cas #1 et #3 et #5
  	      if event.end_date.to_i <= cell_end
  	        #si l'événement se termine dans l'interval, cas #3 et #5
  	        if event.end_date.to_i > cell_begin
              #si l'événement se termine après le debut de l'interval, cas #3
  	          ok = true
  	        end
  	      else
  	        #si l'événement se termine après la fin de l'interval, cas #1
  	        ok = true
  	      end
  	    else
  	      #si l'événement commence apres le debut de l'interval, cas #2 et #4 et #6
  	      if event.end_date.to_i <= cell_end
  	        #si l'événement se termine dans l'interval, cas #2
  	        ok = true
  	      else
  	        #si l'événement se termine après la fin de l'interval, cas #4 et #6
  	        if event.begin_date.to_i < cell_end
  	          #si l'événement commence avant la fin de l'interval, cas #4
  	          ok = true
  	        end
  	      end
  	    end
        return ok
      end
    end

    def display_event(event)
	    #concatenation of title and the event
	    title = link_to "#{event.title}", event
	    #return title of the event
	    event_content = content_tag(:li, title, :class => event.category)
	    #test if content cell is empty
	    return event_content
    end

    def display_events(events)
	    return events_content
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

      #si commence un lundi
      start_on_monday = options[:start_on_monday]

      #first day of month
      first_day_of_month = Time.utc(year, month, 1).wday
      first_day_of_month = shift_week_days(first_day_of_month, 1) if start_on_monday

      #numbers days in month
      days_in_month = Time.utc(year, month, 1).end_of_month.day

      #numbers week in month
      days = (days_in_month + first_day_of_month)
      weeks_in_month = (days / DAYS_IN_WEEK) + (days%DAYS_IN_WEEK != 0 ? 1 : 0)

      #create table include calendar
      days_arr = []

      # initialise counter of journey
      day_counter = 0

      #affichage de la semaine
      current = Date.new(year, month, day)

      #display days of week
      days_name = t('date.day_names').dup

      #on teste si c'est un lundi
      if start_on_monday
        1.times do
          days_name.push(days_name.shift)
        end
      end

      #
      ##
      ###
      #### COMMUN / fin ####


      #si on choisit la semaine
      if display == :week


        #### IF WEEK / debut ####
        ###
        ##
        #


        #on teste si on choisit la semaine
        #generate entete
        if start_on_monday
          day_shift = LUNDI
        else
          day_shift = DIMANCHE
        end
        first_day_of_week = get_day(current, day_shift)

        #on affiche l'entete
        table_head = content_tag(:tr, content_tag('th', 'Horaires') + days_name.enum_for(:each_with_index).collect { |day_name, index| content_tag('th', "#{day_name} #{(first_day_of_week + index).to_s}" ) }.join.html_safe )

        #month_content = content_tag(:thead, content_tag(:tr, content_tag('th', 'horaires') + days_name.collect { |h| content_tag('th', h ) }.join.html_safe ))
        # %w(a b c).enum_for(:each_with_index).collect { |o, i| "#{i}: #{o}" }
        #returns: ["0: a", "1: b", "2: c"]

          suba_content = nil

          #preparation events for each journey
          #sorted events
          events_sorted = events.sort { |x,y| get_event_stamp(x) <=> get_event_stamp(y) } unless events.nil?

          #de 0 à 24h exclut
          (0...HOURS_IN_DAY).each do |hour_index|
            sub_content = content_tag(:tr, nil) do
              hour_content = content_tag(:td, hour_index)
              #on retourne 7 fois le jour
              DAYS_IN_WEEK.times do |index| # 0 1 2 3 4 5 6
                cell_sub_content = nil
                events_sorted.each do |event|
        					#jour courant
        					this_day = (first_day_of_week + index)
        					#on place dans une variable
        					time_of_day = Time.new(this_day.year, this_day.month, this_day.day, hour_index)

        					#affichage
        					ok = display_event?(event, time_of_day, display)
        					#si ok
        					if ok
                    event_content = display_event(event)
        					  if cell_sub_content.nil?
        					    cell_sub_content = event_content
        					  else
        					    cell_sub_content << event_content
        					  end
        					end
                end
                #création liste
                cell_content = content_tag(:ul, cell_sub_content) unless cell_sub_content.nil?
                #on incrémente les jours de la semaine
                hour_content << content_tag(:td, cell_content)
              end
              #renvoie
              hour_content
            end

            #si subcontent est vide on le mets dans suba_content
            suba_content << sub_content unless suba_content.nil?
            #si suba_content est vide on remplace suba_content par sub_content
            suba_content = sub_content if suba_content.nil?
            #on retourne
            suba_content
          end
          #on affiche le contenu
          table_content = content_tag(:div, suba_content)

        #
        ##
        ###
        #### IF WEEK / fin ####

      else
        #sinon c'est le mois

        #### IF MONTH / debut ####
        ###
        ##
        #

        #on affiche l'entete
        table_head = content_tag(:tr, days_name.collect { |h| content_tag('th',h) }.join.html_safe )

        # iteration on each week in month
        weeks_in_month.times do |week_index|
          # iteration on each journey in week
          (0...DAYS_IN_WEEK).each do |day_index|
            #if counter = 0
            if day_counter == 0
              #test beginning of calendar, which begin with the good day in the week
              if day_index != first_day_of_month
                #while we haven't the good day of the week
                #we add x
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
        #tableau de jours
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
          #generate entete
          #month_content = content_tag(:thead,  table_head )
          #while length is positive
          while days_arr.length > 0
            #définition
            week_content =  nil
            #indentation in slice to 7 (DAYS_IN_WEEK) jours
            one_week = days_arr.slice!(0, DAYS_IN_WEEK)
            #we prepare the td in variable
            one_week.each do |one_day|
              # content of a cell
              cell_content = content_tag(:ul, nil) do
                cell_sub_content = nil

                #test day
                if one_day.is_a?(Integer) && !events_by_days[one_day].nil?
                  time_of_day = Time.new(year, month, one_day)

                  # ajout des 'li' uniquement
                  events_by_days[one_day].each do |event|
                    if one_day.is_a?(Integer)
                      ok = display_event?(event, time_of_day, display)
                    end
                    #if ok we concat
                    if ok
                    	event_content = display_event(event)
            					if cell_sub_content.nil?
            					 	cell_sub_content = event_content
            					else
            					    cell_sub_content << event_content
            					end
                    end
                  end
                  
        		  	  toto = capture(time_of_day, &block) if block_given?
        		  	  
        			    cell_sub_content << toto unless cell_sub_content.nil?         			        			   
        			    cell_sub_content = toto if cell_sub_content.nil?         			        			   
                  
                end


        			  #generate markers
        			  content_tag(:div, nil) do
        			    content_tag(:span, one_day) + cell_sub_content
        			  end
              end
                                 
              sub_content = content_tag(:td, cell_content)

               
              if week_content.nil?
                week_content = sub_content
              else
                week_content << sub_content
              end
            end
            #put all the 'td' in 'tr'
            sub_content = content_tag(:tr, week_content)
            if month_content.nil?
              month_content = sub_content
            else
              month_content << sub_content
            end
            #on retourne le résultat
            month_content
          end
          #on affiche le contenu
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
          # affichage de l'entete
          month_content = content_tag(:thead, table_head)
          # affichage du contenu
          month_content << content_tag(:tbody, table_content)
        end

        #
        ##
        ###
        #### DISPLAY / fin ####

    #fin du calendrier
    end
  #fin module
  end
#fin module
end