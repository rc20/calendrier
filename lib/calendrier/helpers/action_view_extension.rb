module Calendrier
  module ActionViewExtension
  
  
    #nombre de jours dans la semaine
    DAYS_IN_WEEK = 7
    
    # renvoie le debut de l'evenement en timestamp
    def get_event_stamp(event, options = {})
      #test des événements
      if event.respond_to?(:year) && event.respond_to?(:month) && event.respond_to?(:day)
        #on affecte le timestamp
        ret = Time.local(event[:year], event[:month], event[:day]).to_i  
      #sinon si l'événement inclut une date de commencement et une date de fin  
      elsif event.respond_to?(:begin_date) && event.respond_to?(:end_date)
        if options[:end_date]
          ret = event[:end_date]
        else
          ret = event[:begin_date]
        end
      end
      #on retourne
      return ret
    end
    
    #affichage d'un calendrier
    def calendrier(events = nil, options = {})
  
      #option année
      year = options[:year] || Time.now.year
  
      #option mois
      month = options[:month] || Time.now.month
      
      #option jour
      day = options[:day] || Time.now.day
      
      #premier jour du mois
      first_day_of_month = Time.local(year, month, 1).wday
      
      #nombre de jours dans le mois
      days_in_month = Time.local(year, month, 1).end_of_month.day   
      
      #nombres de semaines dans le mois
      days = (days_in_month + first_day_of_month)
      weeks_in_month = (days / DAYS_IN_WEEK) + (days%DAYS_IN_WEEK != 0 ? 1 : 0)    
       
      #création du tableau contenant le calendrier
      days_arr = []
      
      # initialisation d'un compteur de journee
      day_counter = 0
      
      # iteration sur chaque semaine du mois  
      weeks_in_month.times do |week_index|
        # iteration sur chaque journee d'une semaine
        (0...DAYS_IN_WEEK).each do |day_index|
        
          #si le compteur est égal à 0
          if day_counter == 0
            # test de debut de calendrier, on commencera quand on aura le bon jour de semaine
            if day_index != first_day_of_month
              # tant qu'on aura pas le bon jour de semaine
              #on rajoute des x
              days_arr << 'x'
            else
              #on ajoute 1 dans le tableau
              days_arr << 1
              
              #on incrémente le compteur
              day_counter += 1
            end
          else
            #si on a le bon jour
            day_counter +=1 
            #si on est toujorus dans le calendrier
            if day_counter <= days_in_month         
              #on ajoute le numéro de jour dans le tableau
              days_arr << day_counter
            else
              # ajout de remplissage a la fin du tableau
              days_arr << 'x'
            end
          end
        end
      end
      
        
      #preparation des evenements de chaque journees    
      #events_by_days[1].each do |events_of_this_day|
      
      #événements triés
      events_sorted = events.sort { |x,y| get_event_stamp(x) <=> get_event_stamp(y) } unless events.nil?
      
      events_by_days = []
      
      # tableau vide d'evenements pour afficher un calendrier simple
      events_sorted = [] if events_sorted.nil?
  
      events_sorted.each do |event|
        # test si la date courante est comprise en "begin_stamp" et "end_stamp" 
        begin_date = Time.at(get_event_stamp(event))
        end_date = Time.at(get_event_stamp(event, :end_date => true))
  
        if (begin_date.year == end_date.year && begin_date.month == end_date.month && begin_date.day == end_date.day)
          # evenement d'une journee
          events_by_days[begin_date.day] = [] if events_by_days[begin_date.day].nil?
          events_by_days[begin_date.day] << event
        else
          # evenement qui dure
          (begin_date.day..end_date.day).each do |event_day|
            events_by_days[event_day] = [] if events_by_days[event_day].nil?
            events_by_days[event_day] << event
            logger.debug event_day
          end
        end
      end
       
      
      #affichage du calendrier
      content_tag(:table, nil) do    
  
        month_content = nil
        
        #tant que la longueur est positive
        while days_arr.length > 0
          week_content =  nil
  
          #decoupage de tranches de 7 (DAYS_IN_WEEK) jours
          one_week = days_arr.slice!(0, DAYS_IN_WEEK)
          
          # on prepare les 'td' dans une variable
          one_week.each do |one_day|
            # contenu d'une cellule
            cell_content = content_tag(:ul, nil) do
              cell_sub_content = nil
  
              #test du jour
              if one_day.is_a?(Integer) && !events_by_days[one_day].nil?
                events_by_days[one_day].each do |event|
  
                  # condition sur l'affichage des événements          
                  if event.respond_to?(:year) && event.respond_to?(:month) && event.respond_to?(:day) && one_day.is_a?(Integer)
                    ok = true if event.year == year && event.month == month && event.day == one_day
                  end
                  logger.debug "ici"
                  if event.respond_to?(:begin_date) && event.respond_to?(:end_date) && one_day.is_a?(Integer)
                    # timestamp du jour 'one_day' a 00h00
                    now = Time.local(year, month, one_day).to_i
                    ok = true if event.begin_date.to_i <= now && now <= event.end_date.to_i 
                  end         
                        
                  #si c'est ok on concatène          
                  if ok
                    #concaténation du titre et de l'événement
                    title = link_to "#{event.title}", event
                    #renvoie du titre de l'événement
                    event_content = content_tag(:li, title, :class => event.category)
                    
                    if cell_sub_content.nil?
                      cell_sub_content = event_content
                    else
                      cell_sub_content << event_content
                    end
                  end                   
                end
              end
  
              #on génère des balises
              content_tag(:div, nil) do
                content_tag(:span, one_day) + cell_sub_content
              end
            end
            sub_content = content_tag(:td, cell_content)
            #on teste si c'est nul
            if week_content.nil?
              week_content = sub_content 
            else
              week_content << sub_content
            end
          end
  
          # on mets l'ensemble des 'td' dans un 'tr'
          sub_content = content_tag(:tr, week_content)
    
          #on teste si c'est nul
          if month_content.nil?
            month_content = sub_content
          else
            month_content << sub_content
          end
        end
        #on renvoie
        month_content
      end 
    end
          
  end
end
