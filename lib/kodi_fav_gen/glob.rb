# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

# Glob a directory to list YML files.
class KodiFavGen::Glob
  autoload(:Pathname, 'pathname')
  autoload(:YAML, 'yaml')

  File.realpath(__FILE__).gsub(/\.rb/, '').then do |path|
    {
      Favourite: :favourite,
    }.each do |k, v|
      autoload(k, "#{path}/#{v}")
    end
  end

  # @param [String] path
  # @param [KodiFavGen::Config] config
  def initialize(path = nil, config: nil)
    self.tap do
      @config = config || ::KodiFavGen::Config.new
      @path = Pathname.new(path || self.config.get(:directory)).realpath.freeze
      @errors = {}
    end.freeze
  end

  # @return [Array<Struct}>]
  def call
    self.glob.map { |item| self.itemize(item) }
  end

  # Get errors encountered during glob and favourites generation.
  #
  # @see #store_error
  #
  # @return [Hash{Symbol => Array<Exception>}]
  def errors
    @errors.dup
  end

  protected

  # @return [Pathname]
  attr_reader :path

  # @return [KodiFavGen::Config]
  attr_reader :config

  # @return [Array<Hash{String => Object}>]
  def glob
    self.path.glob(%w[*.yml *.yml.erb]).map do |file|
      [
        file.basename.to_s.gsub(/\.yml(\.erb)?$/, '').to_sym,
        file
      ]
    end.to_h.values.sort.then do |files|
      files.map do |file|
        Favourite.new(file).then do |favourite|
          favourite.call
        rescue StandardError => error
          store_error(favourite.id, error)
        end
      end
    end.compact
  end

  # Transform given ``Hash`` into ``Struct``.
  #
  # @param [Hash{String => Object}]
  #
  # @return [Struct]
  def itemize(data)
    {
      id: data.fetch('id'),
      name: data.fetch('name'),
      action: data.fetch('action').then do |v|
        v.is_a?(Hash) ? self.actionize(v).to_s : self.actionize({ type: :base, value: v }).to_s
      end,
      hidden: data['hidden'].then { |v| v === true ? true : false },
      thumb: lambda do
        data['thumb_b64']&.then do |b64|
          return ::KodiFavGen::Thumb.new(b64.lines.map(&:chomp).join).call&.to_s
        end

        return nil unless data['thumb']

        Pathname.new(data.fetch('thumb')).then do |thumb|
          ::KodiFavGen::Thumb.new(read_thumb(thumb), base64: false).call.to_s
        rescue StandardError => error
          store_error(data.fetch('id'), error)
        end
      end.call
    }.then { |v| Struct.new(*v.keys, keyword_init: true).new(v) }
  end

  # Create action.
  #
  # @param [Hash{String, Symbol => Object}] statement
  #
  # @return [KodiFavGen::Actions::BaseAction]
  def actionize(statement)
    statement.transform_keys(&:to_s).then do |stt|
      [
        stt.fetch('type'),
        stt.fetch('value'),
        (options = {}).tap do
          stt.each do |k, v|
            next unless /^_[A-Z a-z]/.match(k.to_s)

            options[k.to_s.gsub(/^_/, '').to_sym] = v
          end
        end
      ]
    end.then do |args|
      ::KodiFavGen::Actions.call(*args)
    end
  end

  # Match thumb
  #
  # @param [Pathname] thumb pattern
  #
  # @return [Pathname]
  def match_thumb(thumb)
    return thumb if thumb.file?

    (thumb.absolute? ? thumb.glob('.*') : thumbs_directory.glob("#{thumb}.*")).first.tap do |v|
      if v.nil?
        "Can not match any thumbnail file as #{thumb}"
          .then { |msg| ::KodiFavGen::Errors::MissingFileError.new(msg) }
          .then { |error| raise(error) }
      end
    end
  end

  # @param [Pathname] thumb pattern
  #
  # @return [String]
  def read_thumb(thumb)
    match_thumb(thumb).read
  end

  # @param [String, Pathname] basedir
  #
  # @return [Pathname]
  def thumbs_directory(basedir: nil)
    config.get(:thumbs_directory)&.then do |cpath|
      return Pathname.new(cpath).absolute? ? Pathname.new(cpath) : Pathname.new(path).join(cpath)
    end

    Pathname.new(basedir || path).join('..', 'thumbs')
  end

  # @param [String, Symbol] id
  # @param [StandardError] error
  #
  # @return [nil]
  def store_error(id, error)
    nil.tap do
      @errors[id.to_sym] = (@errors[id.to_sym] || []).concat([error])
    end
  end
end
