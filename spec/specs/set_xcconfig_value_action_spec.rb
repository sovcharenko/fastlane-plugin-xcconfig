require 'xcodeproj'

# https://stackoverflow.com/questions/6227600/how-to-remove-a-key-from-hash-and-get-the-remaining-hash-in-ruby-rails
class Hash
  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end
end

describe Fastlane::Actions::SetXcconfigValueAction do
  describe '#run' do
    def set_xcconfig_value(name, value, file = "set.xcconfig")
      tmp_dir = Dir.mktmpdir('fastlane-plugin-xcconfig ')
      begin
        path = File.join(File.dirname(__FILE__), "fixtures/#{file}")
        before_content = nil

        if File.exist?(path)
          FileUtils.cp(path, tmp_dir)
          path = File.join(tmp_dir, file)
          before_content = Xcodeproj::Config.new(path)
        end

        SpecHelper::FastlaneHelper.execute_as_lane("set_xcconfig_value(path:'#{path}', name: '#{name}', value: '#{value}')")

        after_content = Xcodeproj::Config.new(Xcodeproj::Config.new(path))

        [before_content, after_content]
      ensure
        FileUtils.rm_rf(tmp_dir)
      end
    end

    it 'raises error when file doesn\'t exist' do
      expect { set_xcconfig_value('name1', 'new_value', 'non_existent_file.xcconfig') }.to raise_exception do |exception|
        expect(exception.message).to start_with('Couldn\'t find xcconfig file at path')
      end
    end

    it 'raises error when setting couldn\'t be found' do
      expect { set_xcconfig_value('some_name', 'new_value') }.to raise_exception do |exception|
        expect(exception.message).to start_with('Couldn\'t find \'some_name\' in')
      end
    end

    it 'updates value' do
      {
        'EMPTY' => 'new_value',
        'ARCHS' => 'nil',
        'CLANG_WARN_EMPTY_BODY' => 'NO',
        'PRODUCT_BUNDLE_IDENTIFIER' => 'com.sovcharenko.App-beta',
        'ONLY_ACTIVE_ARCH[config=Debug][sdk=*][arch=*]' => 'NO',
        'ONLY_ACTIVE_ARCH[config=Release]' => 'YES'
      }.each do |key, value|
        before, after = set_xcconfig_value(key, value)
        expect(after.attributes[key]).to eq(value)
        expect(after.attributes.except!(key)).to eq(before.attributes.except!(key))
      end
    end
  end
end
