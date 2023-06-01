# frozen_string_literal: true

# Copyright (C) 2023 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative('../kodi_fav_gen')

# Template (rendering) for ``favourites.xml`` file.
class KodiFavGen::Template
  autoload(:REXML, 'rexml')

  File.realpath(__FILE__).gsub(/\.rb/, '').then do |path|
    {
      ErbFile: :erb_file,
      File: :file,
      String: :string,
    }.each do |k, v|
      autoload(k, "#{path}/#{v}")
    end
  end

  # @api private
  TEMPLATE = ::KodiFavGen::Template::ErbFile.new('main/favourites.xml').freeze

  # @param [KodiFavGen::Glob] glob
  # @param [KodiFavGen::Config] config
  def initialize(glob = nil, config: nil)
    @config = config || ::KodiFavGen::Config.new
    (glob || ::KodiFavGen::Glob.new).tap do |v|
      @path = v.path
    end.call.yield_self do |v|
      @items = self.itemize(v).reject { |item| item.hidden }
    end
  end

  # Render template.
  #
  # @return [String]
  def call
    {
      favourites: items
    }.then do |variables|
      template.call(variables)
    end.then do |xml|
      self.prepare!(xml)
    end.then do |document|
      "#{document.to_s.strip}\n\n"
    end
  end

  protected

  # @return [Pathname]
  attr_reader :path

  # @return [Array<Struct>]
  attr_reader :items

  # @return [KodiFavGen::Config]
  attr_reader :config

  def itemize(glob)
    glob.map do |item|
      {
        id: item.fetch('id'),
        name: item.fetch('name'),
        action: item.fetch('action').lines.map(&:chomp).join,
        hidden: item['hidden'].then { |v| v === true ? true : false },
        thumb: lambda do
          item['thumb_b64']&.yield_self do |b64|
            return ::KodiFavGen::Thumb.new(b64.lines.map(&:chomp).join).call&.to_s
          end

          return nil unless item['thumb']

          Pathname.new(item.fetch('thumb')).yield_self do |thumb|
            (thumb.absolute? ? thumb : thumbs_directory.glob("#{thumb}.*").first).read.yield_self do |v|
              ::KodiFavGen::Thumb.new(v, base64: false).call.to_s
            end
          rescue StandardError => e
            warn("#{e.message} for #{item['id'].inspect}").yield_self { nil }
          end
        end.call
      }.yield_self { |v| Struct.new(*v.keys, keyword_init: true).new(v) }
    end
  end

  # Prepare and validate given xml.
  #
  # @param [String] xml
  #
  # @return [REXML::Document]
  # @raise [REXML::ParseException]
  def prepare!(xml)
    builder = -> (markup) { REXML::Document.new(markup) }

    [
      builder.call("<?xml version='1.0' encoding='%s'?>\n" % ''.encoding),
      builder.call(xml.strip),
    ].then do |header, content|
      header.tap { header.add(content) }
    end
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

  # @return [::KodiFavGen::Template::String]
  def template
    self.class::TEMPLATE
  end
end
