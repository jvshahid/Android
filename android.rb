#!/usr/bin/env ruby

require "term/ansicolor"

String.send :include, Term::ANSIColor

def script_name
  File.basename $0
end

if ARGV.count != 1
  puts "Usage: #{script_name} [setup | update | recover | [upload image_name]]".red
  puts "where: "
  puts "  setup: sets up the android development kit (implies update)"
  puts "  update: run 'android update sdk --fitler 'platform-tool' --no-ui'"
  puts "  recover: installs the original sdk that was shipped with the galaxy s2"
  puts "  clockwork: installs clockworkmod"
  puts "  upload: uploads the given image to your android"
end

def error msg
  puts msg.red
  exit 1
end

def android_sdk_version
  '20.0.1'
end

def android_sdk_url
  "http://dl.google.com/android/android-sdk_r#{android_sdk_version}-linux.tgz"
end

def update
  Dir.chdir 'adk' do
    system("./tools/android update sdk --filter 'platform-tool' --no-ui")
  end
end

def setup
  unless Dir.exists? 'adk'
    Dir.mkdir 'adk'
    Dir.chdir 'adk' do
      system("curl '#{android_sdk_url}' > adk.tar.gz") or error("Cannot retrieve the android sdk from #{android_sdk_url}")
      system("tar --strip-components=1 -xvzf adk.tar.gz")
    end
  end

  if RUBY_PLATFORM =~ /686/
    system("sudo dpkg -i heimdall_1.3.0_i386.deb")
  else
    system("sudo dpkg -i heimdall_1.3.0_amd64.deb")
  end

  update
end

def is_adb_server_up?
  system("pgrep -f adb")
end

def start_adb_server
  system("./adb/platform-tools/adb start-server") unless is_adb_server_up?
end

def stop_adb_server
  system("pkill -f adb")
end

def upload_zimage
  system("sudo heimdall flash --kernel recovery/zImage --factoryfs recovery/factoryfs.img")
end

def prompt
  print "Is your phone in download mode (by turning it off, unplugging usb, holding the volume down and reinserting usb ? [Yn] ".green
  unless STDIN.getc =~ /Y|y/
    puts "Aborting".red
    exit 1
  end
end

def clockworkmod
  prompt
  system("sudo heimdall flash --kernel clockworkmod/zImage")
end

def recover
  prompt
  system("sudo heimdall flash --kernel recovery/zImage --factoryfs recovery/factoryfs.img")
end

def upload
  puts "This step requires manual intervention at the moment".green
  puts "Enter the recovery mode by first turning off the device, then holding volume up, down and power button at the same time".green
  puts "The device should start, then restart and enter into the recovery mode".green
  puts "When in recovery mode, mount the sdcard, then copy the cyanogenmod file to the root directory".green
  puts "Select 'install from sdcard' and select the file that you uploaded".green
  puts "In order to get google apps you have to follow the same instruction to install the google apps zip".green
  puts "Note: each cyanogen mod has its own version of google apps see (http://wiki.cyanogenmod.com/wiki/Latest_Version/Google_Apps)".red
end

if ARGV.first == 'setup'
  setup
elsif ARGV.first == 'update'
  update
elsif ARGV.first == 'recover'
  recover
elsif ARGV.first == 'clockworkmod'
  clockworkmod
elsif ARGV.first == 'upload'
  upload
end

