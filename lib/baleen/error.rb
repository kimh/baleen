module Baleen
  module Error
    class StartContainerFail < StandardError; end
    class ProjectNotFound < StandardError; end
    class ConfigMissing < StandardError; end

    module Validator
      class FrameworkMissing < StandardError; end
      class MandatoryMissing < StandardError; end
    end

  end

end