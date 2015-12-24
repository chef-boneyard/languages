require 'spec_helper'

if windows?
  context 'When on Windows' do
    win_prefix = "\'C:/Program Files (x86)/Microsoft SDKs/F#/4.0/Framework/v4.0/"

    describe command('&' + File.join(win_prefix, 'Fsc.exe\'') + ' /h') do
      its(:stdout) { should start_with 'Microsoft (R) F# Compiler version 14.0.23020.0' }
    end

    describe command('&' + File.join(win_prefix, 'Fsi.exe\'') + "#{chef_file_cache}/fake/test.fsx") do
      its(:stdout) { should match 'Le7s Ship i7 70 7he w0rld' }
    end
  end
else
  context 'When on Linux' do
    describe command(File.join(default_prefix_base, 'fsharp/4.0.1.1/bin', 'fsharpc') + ' --version') do
      its(:stdout) { should start_with 'F# Compiler for F# 4.0 (Open Source Edition)' }
    end

    describe command(File.join(default_prefix_base, 'fsharp/4.0.1.1/bin', 'fsharpi') + " #{chef_file_cache}/fake/test.fsx") do
      its(:stdout) { should match 'Le7s Ship i7 70 7he w0rld' }
    end
  end
end
