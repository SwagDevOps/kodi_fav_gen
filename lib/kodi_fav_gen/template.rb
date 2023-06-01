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
    (glob ||= ::KodiFavGen::Glob.new).tap do |v|
      @items = glob.call.reject { |item| item.hidden }
    end

    freeze
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

  # @return [Array<Struct>]
  attr_reader :items

  # Prepare and validate given xml.
  #
  # @param [String] xml
  #
  # @return [REXML::Document]
  # @raise [REXML::ParseException]
  def prepare!(xml)
    builder = -> (markup) { REXML::Document.new(markup) }

    [
      builder.call("<?xml version='1.0' encoding='#{self.encoding}'?>\n"),
      builder.call(xml.strip),
    ].then do |header, content|
      header.tap { header.add(content) }
    end
  end

  # @return [::KodiFavGen::Template::String]
  def template
    self.class::TEMPLATE
  end

  # Get current encoding.
  #
  # @return [String]
  def encoding
    ''.encoding.to_s
  end
end
