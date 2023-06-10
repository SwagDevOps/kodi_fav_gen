# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../glob')

# Read favourite file as YAML (or ERB flavored YAML file).
#
# File can use ERB template syntax, when using ``.erb.yml`` extension.
# ``variables`` are retrieved from Env Config using ``VAR_`` prefix.
#
# Declare a variable in environment:
# <code>
# export KODI_FAVGEN__VAR__FILES_PATH=/home/john_doe/Public/
# </code>
#
# Use the variable in a YAML favourite file:
# <code>
# # 000_files.yml.erb
# name: Files
# thumb: files
# action:
#   type: activate_window
#   value: <%= files_path.inspect %>
# </code>
class KodiFavGen::Glob::Favourite
  autoload(:Pathname, 'pathname')
  autoload(:YAML, 'yaml')

  # @api private
  VAR_PREFIX = 'var__'

  class << self
    # Read (given) favourite file.
    #
    # @param [String, Pathname] path filepath
    # @param [KodiFavGen::Config] config dependency
    #
    # @return [Hash{String => Object}]
    def call(path, config: nil)
      self.new(path, config: config).to_h
    end
  end

  # @param [String, Pathname] path
  # @param [KodiFavGen::Config] config dependency
  def initialize(path, config: nil)
    self.tap do
      @path = Pathname.new(path.to_s).freeze
      @config = config || ::KodiFavGen::Config.new
    end
  end

  def to_s
    self.path.to_path
  end

  alias to_path to_s

  # @return [Hash{String => Object}]
  def call
    YAML.safe_load(self.read).merge({ 'id' => self.id })
  end

  alias to_h call

  # Extract filename without any extension.
  #
  # @return [String]
  def id
    self.path.basename.to_s.gsub(/\.yml(\.erb)?$/, '')
  end

  protected

  # @return [Pathname]
  attr_reader :path

  # @return [KodiFavGen::Config]
  attr_reader :config

  # Denotes current file is an ERB template.
  #
  # @return [Boolean]
  def erb?
    self.path.extname == '.erb'
  end

  def read
    self.path.read.tap do |content|
      return ::KodiFavGen::Template::String.new(content).call(variables) if self.erb?
    end
  end

  # Gets variables read from Env Config.
  #
  # @return [Hash{Symbol => String}]
  def variables
    self.config.to_h.keep_if do |k, _|
      %r{^#{var_prefix}[a-z]+}.match(k.to_s)
    end.map do |k, v|
      [
        k.to_s.gsub(%r{^#{var_prefix}}, '').to_sym,
        v.to_s.freeze,
      ]
    end.to_h
  end

  # Get prefix used for variables.
  #
  # @return [String]
  def var_prefix
    self.class::VAR_PREFIX
  end
end
