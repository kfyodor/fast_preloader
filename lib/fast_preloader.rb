require 'fast_preloader/version'
require 'fast_preloader/active_record'

module FastPreloader
  autoload :Preloader, 'fast_preloader/preloader'

  # enabled custom preloaders globally
  def self.enable!
    @enabled = true
  end

  def self.disable!
    @enabled = false
  end

  def self.enabled?
    !!@enabled
  end
end

ActiveSupport.on_load(:active_record) do
  FastPreloader::ActiveRecord.init
end
