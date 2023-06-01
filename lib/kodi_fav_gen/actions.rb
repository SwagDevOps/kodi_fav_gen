# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

module KodiFavGen::Actions
  # @type [Hash{Symbol => Class<KodiFavGen::Actions::Base>}]
  @actions = {}

  class << self
    # Factory method to build actions (by name).
    #
    # @param [String, Symbol] action_name
    # @param [String] value
    # @param [Hash, nil] options
    #
    # @return [KodiFavGen::Actions::Base]
    def call(action_name, value, options = {})
      # @type [Class<KodiFavGen::Actions::Base>] klass
      self.actions.fetch(action_name.to_sym).then do |klass|
        klass.new(value, options)
      end
    end

    protected

    # Stored actions.
    #
    # @return [Hash{Symbol => Class<KodiFavGen::Actions::Base>}]
    attr_accessor :actions
  end

  File.realpath(__FILE__).gsub(/\.rb/, '').then do |path|
    {
      Base: :base,
      ActivateWindow: :activate_window,
      YoutubeChannel: :youtube_channel,
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
end
