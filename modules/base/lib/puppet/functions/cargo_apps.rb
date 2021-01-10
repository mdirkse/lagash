# frozen_string_literal: true

require 'open3'

Puppet::Functions.create_function(:cargo_apps) do
  dispatch :cargo_apps do
    param 'String', :username
    param 'String', :user_home
    return_type 'Array'
  end

  def cargo_apps(username, user_home)
    stdout, stderr, status = Open3.capture3("sudo -u #{username} /usr/bin/cargo install --list")

    raise "Could not list installed packages (error: #{stderr})" unless status.exitstatus.zero?

    packages = []

    stdout.each_line do |l|
      next unless l.end_with?(":\n")

      packages.push(l.split(' ')[0])
    end

    packages
  end
end
