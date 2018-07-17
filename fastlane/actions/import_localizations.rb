module Fastlane
  module Actions
    OUTER_CONST = 99  
    SUPPORTED_LANGUAGES = ["de" ,"en-US", "es", "fr", "hu", "it", "ja", "ko", "nl", "pl", "pt-BR", "ru", "zh-CN", "zh-TW"]

    class ImportLocalizationsAction < Action
    
      def self.run(params)
        UI.message "Parameter firefox Folder: #{params[:firefox_folder]}"
        UI.message "Parameter cliqz Folder: #{params[:cliqz_folder]}"
  
        # import Firefox localized strings
        self.import_localization(params[:firefox_folder], "firefox-ios.xliff")

        #import Cliqz localized strings
        self.import_localization(params[:cliqz_folder], "cliqz-ios.xliff")

        # import base language
        UI.message("Import base en language for cliqz localization")
        Actions.sh("xcodebuild -importLocalizations -localizationPath #{params[:cliqz_folder]}/en/cliqz-ios.xliff -project Client.xcodeproj")

      end

      def self.import_localization(directory, xliff_name)
        command_line = ""
        for language in SUPPORTED_LANGUAGES do
          command_line = "xcodebuild -importLocalizations -localizationPath #{directory}/#{language}/#{xliff_name} -project Client.xcodeproj"
          UI.message("import xliff file at #{directory}/#{language}/#{xliff_name}")
          Actions.sh(command_line)
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Import localized constants from both Firefox and Cliqz xliff files"
      end

      def self.details
        ""
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :firefox_folder,
                                       env_name: "FL_IMPORT_BUILD_TOOLS_FIREFOX_FOLDER", # The name of the environment variable
                                       description: "path to get Firefox locatlization xliff files", # a short description of this parameter
                                       verify_block: proc do |value|
                                          raise "No Firefox folder for xliff files given, pass using `firefox_folder: 'path'`".red unless (value and not value.empty?)
                                          # raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :cliqz_folder,
                                       env_name: "FL_IMPORT_BUILD_TOOLS_CLIQZ_FOLDER", # The name of the environment variable
                                       description: "path to get CLiqz locatlization xliff files", # a short description of this parameter
                                       verify_block: proc do |value|
                                          raise "No Cliqz folder for xliff files given, pass using `cliqz_folder: 'path'`".red unless (value and not value.empty?)
                                          # raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                       end)
        ]
      end

      def self.authors
        ["mahmoud@cliqz.com"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
