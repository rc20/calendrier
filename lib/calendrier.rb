require "calendrier/version"
require "calendrier/helpers/action_view_extension"

module Calendrier
  # including our helper into action_view
  ActiveSupport.on_load(:action_view) do
    ::ActionView::Base.send :include, Calendrier::ActionViewExtension
  end
end
