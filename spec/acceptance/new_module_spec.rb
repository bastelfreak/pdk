require 'spec_helper_acceptance'
require 'pdk/version'

describe 'pdk new module' do
  context 'when the --skip-interview option is used' do
    after(:all) do
      FileUtils.rm_rf('new_module')
    end

    describe command('pdk new module new_module --skip-interview') do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stderr) { is_expected.to match(%r{Creating new module: new_module}) }
      its(:stderr) { is_expected.not_to match(%r{WARN|ERR}) }
      its(:stdout) { is_expected.to have_no_output }

      describe file('new_module') do
        it { is_expected.to be_directory }
      end
      # rubocop:disable Style/WordArray
      describe file(File.join('new_module', 'metadata.json')) do
        it { is_expected.to be_file }
        its(:content_as_json) do
          is_expected.to include(
            'name' => match(%r{-new_module}),
            'template-ref' => match(%r{(master-)|(^(tags/)?(\d+)\.(\d+)\.(\d+))}),
            'operatingsystem_support' => include(
              'operatingsystem' => 'Debian',
              'operatingsystemrelease' => ['8', '9'],
            ),
          )
        end
      end

      describe file(File.join('new_module', 'README.md')) do
        it { is_expected.to be_file }
        it { is_expected.to contain(%r{# new_module}i) }
      end

      describe file(File.join('new_module', 'CHANGELOG.md')) do
        it { is_expected.to be_file }
        it { is_expected.to contain(%r{## Release 0.1.0}i) }
      end

      eol_check = '(Get-Content .\new_module\spec\spec_helper.rb -Delimiter [String].Empty) -Match "`r`n"'
      describe command(eol_check), if: Gem.win_platform? do
        its(:stdout) { is_expected.to match(%r{\AFalse$}) }
      end
    end
  end
end
