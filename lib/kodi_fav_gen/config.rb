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

  autoload(:YAML, 'yaml')

  def initialize
    freeze
  end

  # Get config parameter by name.
  #
  # Missing parameters can throw error with ``exception`` option.
  #
  # Given block can be used to easily transform result.
  #
  # Empty strings are retrieved as ``nil`` values.
  #
  # @param [Symbol] name
  # @param [Boolean] exception
  #
  # @return [String, nil, Object]
  def get(name, exception: false, &block)
    key(name.to_s).then { take(_1) }.tap do |v|
      if exception and v.nil?
        raise ::KodiFavGen::Errors::MissingParameterError.from_key(name)
      end
    end.then do
      (block || -> (v) { v }).call(_1)
    end
  end

  # @return [Hash{Symbol => String}]
  def to_h
    /^#{BASE_NAME}__/.then do |rule|
      ENV.keys.keep_if { |k| rule.match(k.to_s) }.map do |k|
        k.gsub(rule, '').downcase.to_sym.then do |key|
          [key, self.take(k)]
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
      defaults_load(defaults)

      payload.map(&:to_s).map do |data|
        parts = data.split('=')
        [parts[0].to_s.tr('-', '_'), parts[1..-1]&.join('=')].map(&:to_s).then do |pair|
          self.set(*pair) unless pair.map(&:empty?).include?(true)
        end
      end.then { self.new }
    end

    # Get defaults.
    #
    # @return [Hash{Symbol => Object, Proc}]
    def defaults
      ::KodiFavGen::Config::Defaults.call
    end

    protected

    # Set value for given key when value is not already set.
    #
    # @param [String] key
    # @param [Object, Proc] value
    #
    # @return [Object]
    def prepare(key, value)
      self.key(key).then do |k|
        (value.is_a?(Proc) ? value.call(self.new.to_h) : value).then do |v|
          ::ENV[k] = YAML::dump(v.to_s).rstrip if !v.to_s.empty? and !::ENV.key?(k)
        end
      end
    end

    # Set value for given key.
    #
    # @param [String] key
    # @param [String, Integer, Boolean] value
    #
    # @return [String, nil]
    def set(key, value)
      self.key(key).then do |k|
        ::ENV[k] = YAML::dump(value)
      end
    end

    # Makes key from given name.
    #
    # @param [String] name
    #
    # @return [String]
    def key(name)
      raise ::ArgumentError, 'name can not be empty' if name.empty?

      {
        base: BASE_NAME,
        name: name.upcase
      }.then { |h| '%<base>s__%<name>s' % h }
    end

    # Load defaults (with given defaults).
    #
    # @param [Hash{Symbol => Object, Proc}] defaults
    def defaults_load(defaults)
      self.defaults.merge(defaults).transform_keys(&:to_s).map do |key, value|
        self.prepare(key, value)
      end
    end
  end

  protected

  # @param [String] name
  #
  # @return [String]
  def key(name)
    self.class.__send__(:key, name)
  end

  # Low-level get implementation
  #
  # @see #get
  #
  # @param [String] key
  #
  # @return [Object, nil]
  def take(key)
    ::ENV[key]&.then do |raw|
      YAML::safe_load(raw.to_s)
    end.then do |v|
      v == '' ? nil : v
    end
  end

  # Reader for defaults file.
  #
  # @see KodiFavGen::Config::Defaults::File
  module Defaults
    class << self
      # Read values for defaults.
      #
      # @return [Hash{Symbol => Object, Proc}]
      def call
        ::File.realpath(__FILE__).gsub(/\.rb$/, '').then do |path|
          require("#{path}/defaults/file")
        end.then do
          ::KodiFavGen::Config::Defaults::File.call
        end
      end
    end
  end
end
