#!/usr/bin/ruby
require 'rubygems'
require 'fileutils'
require 'commander/import'

class ArgumentMissingError < StandardError
end
class MusicMatcher
  DS = '/'
  def self.ls(dir, threshhold)
  threshhold = threshhold || DEFAULT_THRESHHOLD
  dir = dir || Dir.getwd
    Dir.new(dir).each do |e|
      if is_directory?(dir, e)
        if is_album?(dir,e) and created_at_within_threshhold?(dir, e, threshhold)
          puts e
        end
      end
    end
  end

  def self.move(dir, to, threshhold)
    if threshhold.nil? then raise ArgumentMissingError, "Please specify the number of days of old albums to move." end
    threshhold = threshhold || DEFAULT_THRESHHOLD
    dir = dir || Dir.getwd
    to = to || DEFAULT_MUSIC_DIR

    Dir.new(dir).each do |e|
      if is_directory?(dir, e)
        if is_album?(dir,e) and created_at_within_threshhold?(dir, e, threshhold)
          move_file(dir + DS + e, to)
          #puts "#{{ from: dir + DS + e, to: to }}"
        end
      end
    end
  end

  def self.get_threshhold
    DEFAULT_THRESHHOLD
  end

  protected

  def self.move_file(from, to)
    FileUtils.mv from, to
  end

  def self.is_directory?(path, entry)
    File.directory?(path + DS + entry)
  end

  def self.created_at_within_threshhold?(path, entry, threshhold = 30)
    #puts File.mtime(path + DS + entry)
    #puts (Time.now - File.ctime(path + DS + entry)).divmod(86400)
    (Time.now - File.mtime(path + DS + entry)).divmod(86400)[0] > threshhold
  end

  def self.is_album?(path, entry)
    Dir.chdir(path + DS + entry)
    Dir.glob("*.{mp3,flac}").length > 0
  end
end

program :name, 'Music Mover'
program :version, '0.0.2'
program :description, 'Command that moves old music.'

command :ls do |c|
  c.syntax = 'mus ls --dir [dir]'
  c.description = 'Lists music to be moved'
  c.option '--dir STRING', String, 'Specify a directory to search (optional)'
  c.option '--days INTEGER', Integer, 'Specify a threshhold in days (optional)'
  c.action do |args, options|
    options.default \
      :days => 30,
      :dir => '/home/store/TV'

    MusicMatcher.ls(options.dir, options.days)
  end
end

command :move do |c|
  c.syntax = 'mus move --dir [dir]'
  c.description = 'Moves music'
  c.option '--dir STRING', String, 'Specify a directory to search (optional)'
  c.option '--to STRING', String, 'Specify a directory to move files to (optional)'
  c.option '--days INTEGER', Integer, 'Specify a threshhold in days (optional)'
  c.action do |args, options|
    options.default \
      :dir => '/home/store/TV',
      :to => '/Music/Incoming'
    MusicMatcher.move(options.dir, options.to, options.days)
  end
end

default_command :ls
