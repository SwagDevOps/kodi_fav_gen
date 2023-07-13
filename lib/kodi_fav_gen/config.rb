# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

# Describe configuration (from environment).
class KodiFavGen::Config
  # @api private
  BASE_NAME = 'KODI_FAVGEN'

  # @param [Symbol]
  #
  # @return [String, nil]
  def get(name)
    ::ENV[key(name.to_s)]
  end

  # @return [Hash{Symbol => String}]
  def to_h
    /^#{BASE_NAME}__/.then do |rule|
      ENV.keys.keep_if { |k| rule.match(k.to_s) }.map do |k|
        k.gsub(rule, '').downcase.to_sym.then do |key|
          [
            key,
            self.get(key)
          ]
        end
      end.compact.to_h
    end
  end

  class << self
    # @param [Array<String>] payload
    # @param [Hash{String, Symbol => String}]
    #
    # @return [KodiFavGen::Config]
    def call(payload, defaults = {})
      defaults.transform_keys(&:to_s).map do |key, value|
        self.prepare(key, value)
      end

      payload.map(&:to_s).map do |data|
        parts = data.split('=')
        [parts[0].to_s.tr('-', '_'), parts[1..-1]&.join('=')].map(&:to_s).then do |pair|
          self.set(*pair) unless pair.map(&:empty?).include?(true)
        end
      end.then { self.new }
    end

    protected

    # Set value for given key when value is not already set.
    #
    # @param [String] key
    # @param [String] value
    #
    # @return [String, nil]
    def prepare(key, value)
      self.key(key).then do |env_key|
        ::ENV[env_key] = value.to_s unless ::ENV.key?(env_key)
      end
    end

    # Set value for given key.
    #
    # @param [String] key
    # @param [String] value
    #
    # @return [String, nil]
    def set(key, value)
      self.key(key).then do |env_key|
        ::ENV[env_key] = value.to_s unless value.to_s.empty?
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
