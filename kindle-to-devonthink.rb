#!/usr/bin/env ruby
require "appscript"
require "kindleclippings"
include Appscript


#-----------------------------------------------------------------------------
# Config Variables

path_to_clippings = "/Users/willmcneilly/Sites/kindle-backup/My Clippings.txt"
path_to_devon_db = "/Users/willmcneilly/Documents/Test-Db.dtBase2"


#-----------------------------------------------------------------------------
# Open and Parse File

file = File.open( path_to_clippings, 'r')
contents = file.read

parser = KindleClippings::Parser.new
clippings = parser.parse(contents)


#-----------------------------------------------------------------------------
# Open DevonThink Pro and relevant DB

devPro = Appscript.app("DEVONthink Pro")

#close whichever database is open
devPro.database.close
devPro.open_database(path_to_devon_db)

current_db = devPro.current_database


#-----------------------------------------------------------------------------
# Add Clippings

clippings.each do |clipping|
  #create location if it doesn't already exist
  if clipping.type.to_s.include?('Highlight') || clipping.type.to_s.include?('Note')
      folder = current_db.create_location("/#{clipping.book_title}, #{clipping.author}").get
      current_db.create_record_with( { 
          :type_ => :text, 
          :rich_text => "#{clipping.content}",
          :tags => [clipping.author, clipping.book_title, "from kindle" ]
        }, 
        {
          :in => folder
       } )
  end
end
