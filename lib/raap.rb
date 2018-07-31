require 'raap/version'

module Raap
  autoload :Preloader, 'raap/preloader'

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
