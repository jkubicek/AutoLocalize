# encoding: UTF-8
require "yaml"
require "cgi"
require 'open-uri'
require 'json'
require 'iconv'

# Auto localizer. Reads Localizable.strings files and uses google translate to translate them.

source_lang = 'en'
source_path = './'
google_api_host = 'www.googleapis.com'
google_api_path = '/language/translate/v2?'

class Phrase
    attr_accessor :key, :comment
    
    def initialize(key, comment)
        @key = key
        @comment = comment
        @translations = {}
    end
    
    def to_s
        return "{key: \"#{@key}\", comment: \"#{@comment}\"#{@translations}}"
    end
    
    def add_translation(lang, phrase)
        @translations.update({lang => phrase})
    end
    
    def translation_for(lang)
        @translations[lang]
    end
end

# Read configuration file to get google API key
api_key = YAML::parse_file('config.yaml')['GoogleAPIKey'].transform

# Read directory to get source Localizable.strings file
Dir.chdir(source_path)
source_file = ""
dest_files = []

Dir.glob("*.lproj") {|file|
	strings = "#{file}/Localizable.strings"
	if File.exists?(strings)
		if file.split('.')[0] == source_lang
			source_file = strings
		else
			dest_files << strings
		end
	else
        dest_files << strings
    end
}

p "Source strings file: #{source_file}"
p "Destination strings files: #{dest_files}"

# Parse files
#############

#Open source file and pull out strings
f = File.open(source_file, "r:UTF-16LE")

phrases = []

begin
    while line = f.readline do
        if line.start_with?("/* ")
            comment = line.sub("/* ", "").sub(" */", "").chomp
            keys = f.readline.split("\" = \"")
            key = keys[0]
            key.slice!(0)
            phrases << Phrase.new(key, comment)
        end
    end
rescue EOFError
    f.close
end


# Translate files
#################

p "Starting translation of #{phrases.count} phrases..."

dest_files.each {|dest_file|
    target_lang = dest_file[0,2]
    p "******************************"
    p "Starting translations for #{target_lang}"
    done = 0
    phrases.each {|phrase|
        escaped_phrase = CGI.escape(phrase.key)
        path = "https://#{google_api_host}#{google_api_path}key=#{api_key}&source=#{source_lang}&target=#{target_lang}&q=#{escaped_phrase}" 
        open(path) {|f|
            f.each_line {|line| 
                result = JSON.parse(line)
                phrase.add_translation(target_lang, result["data"]["translations"][0]["translatedText"])
                done = done.next
                p "Translation #{done} of #{phrases.count} complete..."
            }
        }
    }
    File.open(dest_file, "w:UTF-16LE") {|file|
    p "******************************"
    p "Writing translated phrases to \"#{dest_file}\""
        phrases.each {|phrase|
            file.write "/* #{phrase.comment} */\n"
            trans_string = phrase.translation_for(target_lang)
            file.write "\"#{phrase.key}\" = \"#{trans_string}\";\n"
            file.write "\n"
        }
    }
}

