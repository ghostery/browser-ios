module Fastlane
  module Actions
    OUTER_CONST = 99  
    class ImportCliqzLocalizationsAction < Action
    
      def self.run(params)
        UI.message "Parameter cliqz l10n Folder: #{params[:l10n_folder]}"
  
        #import Cliqz localized strings
        self.import_localization(params[:l10n_folder], params[:app_name], "cliqz-ios.xliff")
      end

      def self.import_localization(directory, app_name, xliff_name)
        supportedLanguages = File.readlines("shipping_locales.txt")
        command_line = ""
        
        for supportedLanguage in supportedLanguages do
          language = supportedLanguage.strip
          filePath = "#{directory}/#{language}/#{xliff_name}"
          Actions.sh("source import-locales-env/bin/activate && fastlane/scripts/inject_app_name.py #{filePath} #{app_name}")

          command_line = "xcodebuild -importLocalizations -localizationPath #{filePath} -project Client.xcodeproj"
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
          FastlaneCore::ConfigItem.new(key: :l10n_folder,
                                       env_name: "FL_IMPORT_BUILD_TOOLS_CLIQZ_L10N_FOLDER", # The name of the environment variable
                                       description: "path to get CLiqz locatlization xliff files", # a short description of this parameter
                                       verify_block: proc do |value|
                                          raise "No Cliqz l10 folder for xliff files given, pass using `l10n_folder: 'path'`".red unless (value and not value.empty?)
                                          # raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_name,
                                       env_name: "FL_IMPORT_BUILD_TOOLS_CLIQZ_APP_NAME", # The name of the environment variable
                                       description: "Localized app name", # a short description of this parameter
                                       verify_block: proc do |value|
                                          raise "No Cliqz App name given, pass using `app_name: 'name'`".red unless (value and not value.empty?)
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
