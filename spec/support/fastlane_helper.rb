module SpecHelper
  class FastlaneHelper
    def self.execute_as_lane(lane)
      Fastlane::FastFile.new.parse("lane :test do #{lane} end").runner.execute(:test)
    end
  end
end
