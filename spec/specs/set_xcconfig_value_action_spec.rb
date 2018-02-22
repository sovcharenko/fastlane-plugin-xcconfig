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
    before(:each) do
      allow(FastlaneCore::Helper).to receive(:sh_enabled?).and_return(true)
      @tmp_dir = Dir.mktmpdir('fastlane-plugin-xcconfig ')
    end

    after(:each) do
      FileUtils.rm_rf(@tmp_dir)
    end

    def set_xcconfig_value(name, value, file = "set.xcconfig")
      path = File.join(File.dirname(__FILE__), "fixtures/#{file}")
      before_content = nil

      if File.exist?(path)
        FileUtils.cp(path, @tmp_dir)
        path = File.join(@tmp_dir, file)
        before_content = Xcodeproj::Config.new(path)
      end

      SpecHelper::FastlaneHelper.execute_as_lane("set_xcconfig_value(path:'#{path}', name: '#{name}', value: '#{value}')")

      after_content = Xcodeproj::Config.new(Xcodeproj::Config.new(path))

      [before_content, after_content]
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
      before, after = set_xcconfig_value('name1', 'new_value')
      expect(after.attributes['name1']).to eq('new_value')
      expect(after.attributes.except!('name1')).to eq(before.attributes.except!('name1'))
    end

    it 'updates value (subscript)' do
      before, after = set_xcconfig_value('name2[sub1=x86][sub2=os]', 'new_value')
      expect(after.attributes['name2[sub1=x86][sub2=os]']).to eq('new_value')
      expect(after.attributes.except!('name2[sub1=x86][sub2=os]')).to eq(before.attributes.except!('name2[sub1=x86][sub2=os]'))
    end

    it 'strips out comments and updates value' do
      before, after = set_xcconfig_value('name3', 'new_value')
      expect(after.attributes['name3']).to eq('new_value')
      expect(after.attributes.except!('name3')).to eq(before.attributes.except!('name3'))
    end

    it 'updates empty value' do
      before, after = set_xcconfig_value('name5', 'new_value')
      expect(after.attributes['name5']).to eq('new_value')
      expect(after.attributes.except!('name5')).to eq(before.attributes.except!('name5'))
    end

    it 'trims name and updates value' do
      before, after = set_xcconfig_value('name6', 'new_value')
      expect(after.attributes['name6']).to eq('new_value')
      expect(after.attributes.except!('name6')).to eq(before.attributes.except!('name6'))
    end

    it 'doesn\'t update invalid settings' do
      ['iname1', 'iname2[]', 'iname//3', 'iname4'].each do |name|
        expect { set_xcconfig_value(name, 'new_value') }.to raise_exception do |exception|
          expect(exception.message).to start_with("Couldn't find '#{name}' in")
        end
      end
    end
  end
end
