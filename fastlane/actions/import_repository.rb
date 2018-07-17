module Fastlane
  module Actions
    
    class ImportRepositoryAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "Parameter URL: #{params[:url]}"
        UI.message "Parameter Clone Folder: #{params[:clone_folder]}"
        UI.message "Parameter Branch: #{params[:branch]}"
        directory = params[:clone_folder]

        git_command = ""
        if File.directory?(directory)
          UI.message("Fetching latest version of build tools from #{directory}")
          branch_option = ""
          branch_option = "git checkout #{params[:branch]}\n" if params[:branch] != 'HEAD'
          git_command = "cd #{directory}\n \
          git checkout master\n \
          git fetch\n \
          #{branch_option} \
          git pull"
        else
          UI.message("Cloning build tools repository")
          #import from git into subdir
          branch_option = ""
          branch_option = "--branch #{params[:branch]}" if params[:branch] != 'HEAD'

          git_command = "git clone '#{params[:url]}' '#{directory}' #{branch_option}"
        end

        UI.message("Excuting #{git_command}")
        Actions.sh(git_command)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Downloads an Git repo to a given location"
      end

      def self.details
        "Downloads a Git repo <:url> to a given location <:clone_folder> and checks out a specific branch if <:branch> is provided"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: "FL_IMPORT_BUILD_TOOLS_URL", # The name of the environment variable
                                       description: "URL of github repository that contains build tools", # a short description of this parameter
                                       verify_block: proc do |value|
                                          raise "No URL for ImportBuildToolsAction given, pass using `url: 'value'`".red unless (value and not value.empty?)
                                          # raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :clone_folder,
                                       env_name: "FL_IMPORT_BUILD_TOOLS_CLONE_FOLDER", # The name of the environment variable
                                       description: "path to import build tools to", # a short description of this parameter
                                       verify_block: proc do |value|
                                          raise "No Clone folder for ImportBuildToolsAction given, pass using `clone_folder: 'path'`".red unless (value and not value.empty?)
                                          # raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :branch,
                                       env_name: "FL_IMPORT_BUILD_TOOLS_BRANCH",
                                       description: "Branch of build tools to import",
                                       default_value: "HEAD") # the default value if the user didn't provide one
        ]
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Mozilla"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
