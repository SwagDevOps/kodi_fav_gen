# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# Namespace module
module KodiFavGen
  class << self
    protected

    # Denote given constant is already defined for the class.
    #
    # @api private
    #
    # @param [String, Symbol] constant
    def has_constant?(constant)
      self.constants.map(&:to_sym).include?(constant.to_sym)
    end
  end

  ::File.realpath(__FILE__).gsub(/\.rb$/, '').tap do |path|
    {
      Actions: :actions,
      App: :app,
      Concerns: :concerns,
      Config: :config,
      Errors: :errors,
      Git: :git,
      Glob: :glob,
      Output: :output,
      Template: :template,
      Thumb: :thumb,
    }.each do |k, v|
      autoload(k, "#{path}/#{v}")
    end
  end.tap do |path|
    # @api private
    ERB_PATH = "#{path}/erb" unless has_constant?(:ERB_PATH)
  end

  KodiFavGen::App.call if __FILE__ == $0
end

