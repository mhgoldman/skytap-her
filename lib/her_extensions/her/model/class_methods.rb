module Her
  module Model
    module ClassMethods
      def use_collection_finders(setting=true)
        @use_collection_finders = setting
      end

      def using_collection_finders?
        !!@use_collection_finders
      end
    end
  end
end