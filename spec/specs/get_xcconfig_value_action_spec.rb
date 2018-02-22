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
      expect(get_xcconfig_value('name1')).to eq('value1')
    end

    it 'returns value (subscript)' do
      expect(get_xcconfig_value('name2[sub1=x86][sub2=os]')).to eq('value2')
    end

    it 'strips out comments and returns value' do
      expect(get_xcconfig_value('name3')).to eq('value3')
    end

    it 'reads empty value' do
      expect(get_xcconfig_value('name5')).to eq('')
    end

    it 'reads and trims name and value' do
      expect(get_xcconfig_value('name6')).to eq('value  6')
    end

    it 'doesn\'t read invalid settings'  do
      ['iname1', 'iname2[]', 'iname//3', 'iname4'].each do |name|
        expect { get_xcconfig_value(name) }.to raise_exception do |exception|
          expect(exception.message).to start_with("Couldn't read '#{name}' from")
        end
      end
    end
  end
end
