# Be sure to restart your server when you modify this file.

ArchivesSpaceApiUtility.configure do |config|

  config.host = ENV['archivesspace_backend_host'] ?
      ENV['archivesspace_backend_host'] : ENV['archivesspace_host']
  config.port = ENV['archivesspace_backend_port'] ?
      ENV['archivesspace_backend_port'].to_i : nil
  config.username = ENV['archivesspace_username']
  config.password = ENV['archivesspace_password']
  config.https = ENV['archivesspace_https']

end
