# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

# Read path of ``tmpdir`` from config, env or defaults to native ruby feature.
class KodiFavGen::Tmpdir
  # @param [KodiFavGen::Config] config
  def initialize(config: nil)
    (from(config)&.tap { @configured = true } || ::ENV['TMPDIR'] || lambda do
      require('tmpdir').then { ::Dir.tmpdir }
    end.call).then do |tmpdir|
      Pathname.new(tmpdir).expand_path
    end.tap { |v| @path = v }

    freeze
  end

  # Denote ``tmpdir`` was seen from config.
  #
  # @return [Boolean]
  def configured?
    # noinspection RubySimplifyBooleanInspection
    !!@configured
  end

  # @return [Pathname]
  def path
    Pathname.new(@path)
  end

  # @return [String]
  def to_s
    self.path.to_s
  end

  # @param [String, Pathname] segments
  #
  # @return [Pathname]
  def join(*segments)
    self.path.join(*segments)
  end

  # @return [Boolean]
  def directory?
    self.path.directory?
  end

  alias to_path to_s

  alias directory path

  protected

  # @param [KodiFavGen::Config, nil] config
  #
  # @return [Pathname, nil]
  def from(config)
    (config || ::KodiFavGen::Config.new).get(:tmpdir)
  end
end
