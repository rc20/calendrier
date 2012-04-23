module Calendrier 
  module ActionViewExtension

  
    #numbers of days in the week
    DAYS_IN_WEEK = 7
    #numbers of hours in day
    HOURS_IN_DAY = 24
    
    
    # return the beginning of event in timestamp
    def get_event_stamp(event, options = {})
      #tests events
      if event.respond_to?(:year) && event.respond_to?(:month) && event.respond_to?(:day)
        #affect the timestamp
        ret = Time.local(event[:year], event[:month], event[:day]).to_i  
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
    end

    #récupère jour
    def get_day(current, wday)  
      if wday == 0
        #si le jour est un dimanche on incrémente
        increment = 7
      else
        #sinon on incrémonte pas
        increment = 0
      end
      #decalage si on arrive en fin de mois
      days_shift = (current.wday - wday)
      #jour courant
      current - days_shift + increment
    end


    #display calendar
    def calendrier(events = nil, options = {})

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

      #####

      #affichage de la semaine
      current = Date.new(year, month, day)
      
      #display days of week
      days_name = t('date.day_names').dup
          
      if start_on_monday
        1.times do
          days_name.push(days_name.shift)
        end
      end
  
  
#  content_tag(:td, 'rdv') + content_tag(:td, 'formation') + content_tag(:td, 'conference') + content_tag(:td, 'reunion') + content_tag(:td, 'bilan') + content_tag(:td, 'test') + content_tag(:td, 'test')          

  
  
      return content_tag(:table, nil) do
        #generate entete
        month_content = content_tag(:thead, content_tag(:tr, content_tag('th', 'horaires') + days_name.collect { |h| content_tag('th',h) }.join.html_safe ))     

        lundi = get_day(current, 1) 
        month_content << content_tag(:tbody, nil) do
          suba_content = nil
          #de 0 à 24h exclut
          (0...HOURS_IN_DAY).each do |hour_index|         
            sub_content = content_tag(:tr, nil) do
              hour_content = content_tag(:td, hour_index)    

              #on retourne 7 fois le jour  
              DAYS_IN_WEEK.times do |index|
                #on incrémente les jours de la semaine
# puts lundi + index
                hour_content << content_tag(:td, lundi + index)
              end
              hour_content
            end
            suba_content << sub_content unless suba_content.nil?              
            suba_content = sub_content if suba_content.nil?
          end
          suba_content
        end 
      end
              
      
############################### WEEK
      return
############################### MONTH        



      #first day of month
      first_day_of_month = Time.local(year, month, 1).wday
      first_day_of_month = shift_week_days(first_day_of_month, 1) if start_on_monday
       
      #numbers days in month
      days_in_month = Time.local(year, month, 1).end_of_month.day   
      
      #numbers week in month
      days = (days_in_month + first_day_of_month)
      weeks_in_month = (days / DAYS_IN_WEEK) + (days%DAYS_IN_WEEK != 0 ? 1 : 0)    
       
      #create table include calendar
      days_arr = []
      
      # initialise counter of journey
      day_counter = 0
      
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
      #sorted events
      events_sorted = events.sort { |x,y| get_event_stamp(x) <=> get_event_stamp(y) } unless events.nil?
      
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
            logger.debug event_day
          end
        end
      end
      
      #display calendar
      content_tag(:table, nil) do
        month_content = nil
              
        #display days of week
        days_name = t('date.day_names').dup
          
        #utilisation méthode dub
#        days_name = days_name.dup
        
        if start_on_monday
          1.times do
            days_name.push(days_name.shift)
          end
        end
  
        #generate entete
        month_content = content_tag(:thead, content_tag(:tr, days_name.collect { |h| content_tag('th',h) }.join.html_safe ))     
      
        #while length is positive
        while days_arr.length > 0
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
                events_by_days[one_day].each do |event|
  
                  #condition on display events        
                  if event.respond_to?(:year) && event.respond_to?(:month) && event.respond_to?(:day) && one_day.is_a?(Integer)
                    ok = true if event.year == year && event.month == month && event.day == one_day
                  end
                  logger.debug "ici"
                  if event.respond_to?(:begin_date) && event.respond_to?(:end_date) && one_day.is_a?(Integer)
                    # timestamp du jour 'one_day' à 00h00
                    now = Time.local(year, month, one_day).to_i
                    ok = true if event.begin_date.to_i <= now && now <= event.end_date.to_i 
                  end         
                        
                  #if ok we concat         
                  if ok
                    #concatenation of title and the event
                    title = link_to "#{event.title}", event
                    #return title of the event
                    event_content = content_tag(:li, title, :class => event.category)                     
                    #test if content cell is empty
                    if cell_sub_content.nil?
                      cell_sub_content = event_content
                    else
                      cell_sub_content << event_content
                    end
                  end                   
                end
              end
  
              #generate markers
              content_tag(:div, nil) do
                content_tag(:span, one_day) + cell_sub_content
              end
            end
            sub_content = content_tag(:td, cell_content)
            #if test is null
            if week_content.nil?
              week_content = sub_content 
            else
              week_content << sub_content
            end
          end
  
          #put all the 'td' in 'tr'
          sub_content = content_tag(:tr, week_content)
    
          #test if null
          if month_content.nil?
            month_content = sub_content
          else
            month_content << sub_content
          end
        end
        #return result
        month_content
      end 
    end       
  end
end
