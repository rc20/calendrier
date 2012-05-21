require "calendrier/version"
require "calendrier/controllers/action_controller_extension"
require "calendrier/helpers/action_view_extension"

module Calendrier
  # including our helper into action_view
  ActiveSupport.on_load(:action_view) do
    ::ActionView::Base.send :include, Calendrier::ActionViewExtension
  end
  ActiveSupport.on_load(:action_controller) do                                                                                                                          
    ::ActionController::Base.send :include, Calendrier::ActionControllerExtension
  end
end
