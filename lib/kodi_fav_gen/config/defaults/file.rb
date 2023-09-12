# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../../config')

# Describe defaults file.
class KodiFavGen::Config::Defaults::File
  autoload(:Pathname, 'pathname')

  class << self
    # Read values for defaults.
    #
    # @return [Hash{Symbol => Object, Proc}]
    def call
      self.new.read
    end
  end

  def initialize
    self.tap do
      @path = Pathname.new(__FILE__).dirname.join('..', 'defaults.rb').realpath.freeze
    end.freeze
  end

  # Read defaults.
  #
  # @return [Hash{Symbol => Object, Proc}]
  def to_h
    self.instance_eval(path.read, path.to_path, 1)
  end

  alias read to_h

  # @return [String]
  def to_path
    path.to_path
  end

  alias to_s to_path

  protected

  # @return [Pathname]
  attr_reader :path
end
