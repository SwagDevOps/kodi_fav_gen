# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../app')

# Namespace and factory.
module KodiFavGen::App::Actions
  # @type [Hash{Symbol => Class<KodiFavGen::App::Actions::Base>}]
  @actions = {}

  class << self
    # Stored actions.
    #
    # @return [Hash{Symbol => Class<KodiFavGen::App::Actions::Base>}]
    attr_accessor :actions
  end

  ::File.realpath(__FILE__).gsub(/\.rb$/, '').then do |path|
    {
      Generate: :generate,
      Config: :config,
    }.each do |k, v|
      autoload(k, "#{path}/#{v}")

      self.const_get(k).tap do |klass|
        {
          v.to_sym => klass,
          k.to_sym => klass,
        }.then { |h| self.actions.merge!(h) }
      end
    end
  end

  class << self
    # @param [Symbol] action_name
    # @param [Array<String>, nil] argv
    # @param [Hash{String, Symbol => String}] defaults
    #
    # @return [KodiFavGen::App::Actions::Base]
    def call(action_name, argv = nil, defaults = {})
      # @type [Class<KodiFavGen::App::Actions::Base>] klass
      self.actions.fetch(action_name.to_sym).then do |klass|
        klass.new(argv, defaults)
      end
    end
  end
end
