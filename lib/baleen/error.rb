module Baleen
  module Error
    class StartContainerFail < StandardError; end

    module Validator
      class FrameworkMissing < StandardError; end
      class MandatoryMissing < StandardError; end
    end

  end

end