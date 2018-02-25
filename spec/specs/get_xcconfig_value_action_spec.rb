describe Fastlane::Actions::GetXcconfigValueAction do
  describe '#run' do
    def get_xcconfig_value(name, file = "get.xcconfig")
      path = File.join(File.dirname(__FILE__), "fixtures/#{file}")
      SpecHelper::FastlaneHelper.execute_as_lane("get_xcconfig_value(path:'#{path}', name: '#{name}')")
    end

    it 'raises error when file doesn\'t exist' do
      expect { get_xcconfig_value('name1', 'non_existent_file.xcconfig') }.to raise_exception do |exception|
        expect(exception.message).to start_with('Couldn\'t find xcconfig file at path')
      end
    end

    it 'raises error when setting couldn\'t be found' do
      expect { get_xcconfig_value('some_name') }.to raise_exception do |exception|
        expect(exception.message).to start_with('Couldn\'t read \'some_name\' from')
      end
    end

    it 'returns value' do
      {
        'EMPTY' => '',
        'ARCHS' => '$(ARCHS_STANDARD)',
        'CLANG_WARN_EMPTY_BODY' => 'YES',
        'PRODUCT_BUNDLE_IDENTIFIER' => 'com.sovcharenko.App',
        'ONLY_ACTIVE_ARCH[config=Debug][sdk=*][arch=*]' => 'YES',
        'ONLY_ACTIVE_ARCH[config=Release]' => 'NO'
      }.each do |key, value|
        expect(get_xcconfig_value(key)).to eq(value)
      end
    end

    it 'ignores invalid settings' do
      ['1FOO', 'FOO', 'FOO//BAR', 'FOO BAR'].each do |name|
        expect { get_xcconfig_value(name) }.to raise_exception do |exception|
          expect(exception.message).to start_with("Couldn't read '#{name}' from")
        end
      end
    end
  end
end
