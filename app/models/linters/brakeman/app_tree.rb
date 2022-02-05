require 'brakeman/app_tree'

module Linters
  class Brakeman < Linters::Base
    class AppTree < ::Brakeman::AppTree
      VIEW_EXTENSIONS = %w(html.erb html.haml rhtml js.erb html.slim).join(',')

      attr_reader :root, :file

      def self.from_options(file)
        root = ''

        # Convert files into Regexp for matching
        init_options = {
          only_files: file.path
        }
        new(file, root, init_options)
      end

      def initialize(file, root, init_options = {})
        @file = file
        @root = root
        @skip_files = init_options[:skip_files]
        @only_files = init_options[:only_files]
        @additional_libs_path = init_options[:additional_libs_path] || []
      end

      def expand_path(path)
        File.expand_path(path, @root)
      end

      def read(_path)
        file.blob
      end

      def read_path(_path)
        file.blob
      end

      def exists?(_path)
        true
      end

      def path_exists?(_path)
        true
      end

      def category_paths(name, root)
        @category_paths ||= {}
        @category_paths[name] ||=
          if file.path.starts_with?(root)
            [file.path]
          else
            []
          end
      end

      def initializer_paths
        category_paths(:initializer, 'config/initializers')
      end

      def controller_paths
        category_paths(:controller, 'app/controllers')
      end

      def model_paths
        category_paths(:model, 'app/models')
      end

      def template_paths
        category_paths(:template, 'app/views')
      end

      def layout_exists?(_name)
        true
      end

      def lib_paths
        []
      end
    end
  end
end
