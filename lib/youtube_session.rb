require 'google/api_client'
require 'json'

module YoutubeSession
    API_KEY = ENV['YOUTUBE_API_KEY'] # Any IP allowed, user: dan@sofarsounds.com

    def self.new(channel_short_name, max_pages_processed = nil)
      puts "Fetching channel: #{channel_short_name}"

      client = Google::APIClient.new(:application_name => "Sofar Sounds",:application_version => "0.1")

      auth_email =  ENV['YOUTUBE_AUTH_EMAIL']
      auth_scope =  "https://www.googleapis.com/auth/youtube.readonly"

      client.authorization = Signet::OAuth2::Client.new(
       :token_credential_uri  => 'https://accounts.google.com/o/oauth2/token',
       :audience              => 'https://accounts.google.com/o/oauth2/token',
       :scope                 => auth_scope,
       :issuer                => auth_email,
       :signing_key           => Google::APIClient::KeyUtils.load_from_pkcs12("config/google_drive.p12", "notasecret")
      )

      # GET OAUTH TOKEN
      token                   = client.authorization.fetch_access_token!
      token_str               = token["access_token"]

      # DISCOVER YOUTUBE API
      youtube                 = client.discovered_api('youtube', 'v3')

      # QUERY CHANNEL INFO
      channel_result          = client.execute(key: API_KEY, api_method: youtube.channels.list, parameters: {forUsername: channel_short_name, part: 'contentDetails'})
      channel_result_data     = JSON.parse(channel_result.data.to_json)

      # FETCH UPLOADS PLAYLIST
      uploads_playlist_str    = channel_result_data["items"][0]["contentDetails"]["relatedPlaylists"]["uploads"]

      puts "Playlist ID: #{uploads_playlist_str}"

      # QUERY UPLOADS PLAYLIST (proper api method name: playlistItems.list, ruby converts camel-case)
      video_results           = []
      next_page_token         = nil
      pages_processed         = 0

      # playlist_result       = client.execute(key: API_KEY, api_method: youtube.playlist_items.list, parameters: {playlistId: uploads_playlist_str, part: 'snippet', resultsPerPage: 50})
      # playlist_result_data  = JSON.parse(playlist_result.data.to_json)

      puts "Fetching videos ..."
      loop do
        pages_processed       = pages_processed + 1

        playlist_result       = client.execute(key: API_KEY, api_method: youtube.playlist_items.list, parameters: {playlistId: uploads_playlist_str, part: 'snippet', resultsPerPage: 50, nextPageToken: next_page_token})
        playlist_result_data  = JSON.parse(playlist_result.data.to_json)

        # Add this page of results to pile
        playlist_result_items = playlist_result_data["items"]
        video_results         += playlist_result_items if playlist_result_items

        # Assign new page token or finish
        break unless playlist_result_data.has_key?("nextPageToken")
        next_page_token       = playlist_result_data["nextPageToken"]

        # finish if over pages max
        break if !playlist_result_items or (!max_pages_processed.blank? and (pages_processed >= max_pages_processed))

        print "#{video_results.count}..."
      end
      puts "DONE"
      puts ""

      return video_results
    end
end
