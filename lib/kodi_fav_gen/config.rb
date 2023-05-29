# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

# Describe configuration (from environment).
class KodiFavGen::Config
  BASE_NAME = 'KODI_FAV'

  # @param [Symbol]
  #
  # @return [String, nil]
  def get(name)
    ::ENV[key(name.to_s)]
  end

  class << self
    # @param [Array<String>] payload
    #
    # @return [KodiFavGen::Config]
    def call(payload)
      payload.map(&:to_s).map do |data|
        parts = data.split('=')
        [parts[0].to_s, parts[1..-1]&.join('=')].map(&:to_s).yield_self do |pair|
          self.set(*pair) unless pair.map(&:empty?).include?(true)
        end
      end.yield_self { self.new }
    end

    protected

    def set(key, value)
      self.key(key).yield_self do |env_key|
        ::ENV[env_key] = value unless value.to_s.empty?
      end
    end

    # @param [String] name
    #
    # @return [String, nil]
    def key(name)
      return nil if name.empty?

      [BASE_NAME, name.upcase].join('__')
    end
  end

  protected

  # @param [String] name
  #
  # @return [String]
  def key(name)
    self.class.__send__(:key, name)
  end
end
