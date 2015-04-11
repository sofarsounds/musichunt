unless Rails.env.production?
  ENV['SITE_TITLE']         = "MusicHunt"
  ENV['SEO_TITLE']          = "Music recommendations from the Sofar Sounds community."
  ENV['YOUTUBE_API_KEY']    = "AIzaSyCxm8PfAjo4NDwbfmnHytIDFI1MQc6MNzI"
  ENV['YOUTUBE_AUTH_EMAIL'] = "389297063012-e1a7j3hrpadc678rbdkt8rlv4blaq4j2@developer.gserviceaccount.com"
end