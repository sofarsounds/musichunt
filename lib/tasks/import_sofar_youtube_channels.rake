require 'youtube_session'

namespace :sofar do
  namespace :youtube do

    desc "Import Youtube data -> gdoc, Use arg to limit pages: import[5]"
    task :import, [:pages] => :environment do |t, args|
      #max_pages_processed = args.pages.blank? ? nil : args.pages.to_i
      max_pages_processed = args.pages.blank? ? 10 : args.pages.to_i

      # channels = ["sofarsounds", "sofaralt", "SofarLatinAmerica", "sofaracoustic", "sofarelectronic", "sofarglobal", "sofarbass"]
      channels = ["sofarsounds", "sofaralt", "SofarLatinAmerica", "sofaracoustic", "sofarglobal"]

      puts ""
      puts "Looping #{channels.count} channels..."
      puts ""

      # Loop channels
      for channel_username in channels
        puts "############################################################################"
        puts "CHANNEL: #{channel_username}"
        puts ""

        videos = YoutubeSession.new(channel_username, max_pages_processed)
        puts "VID COUNT: #{videos.count}"

        for video in videos

          id            = video["snippet"]["resourceId"]["videoId"]
          video_link    = "http://youtube.com/watch?v=#{id}"

          # Look for video url
          video_exists = Item.find_by_url(video_link) ? true : false

          unless video_exists
            pub_date      = video["snippet"]["publishedAt"]
            pub_date_str  = Chronic.parse(pub_date).strftime("%d/%m/%Y")

            video_title   = video["snippet"]["title"]

            artist        = video_title.split(" - ").first
            song          = video_title.split(" - ").last.split(" | ").first
            location      = video_title.split(" | Sofar ").last.split(" (").first

            description   = video["snippet"]["description"]

            # DEBUG
            # next unless artist == "Gionata Mirai"

            # Check UUID string is numeric!
            uuid          = "NA"
            uuid_tmp      = video_title.split(" (#").last.split(")").first
            uuid          = uuid_tmp if uuid_tmp.to_i.to_s == uuid_tmp

            # Look for av team credits
            who_edit      = "NA"
            who_sound     = "NA"
            who_video     = "NA"
            description.each_line do |line|
              who_video   = line.split(": ").last if line.start_with?('Filmed by') or line.start_with?('Filmed & Edited by')
              who_edit    = line.split(": ").last if line.start_with?('Edited by') or line.start_with?('Filmed & Edited by')
              who_sound   = line.split(": ").last if line.start_with?('Audio by')
            end

            # Look for gig date
            gig_date_str      = "NA"
            gig_date_matches  = description.scan(/ on (.*)/)
            if gig_date_matches
              for gig_date_match in gig_date_matches
                # pp gig_date_match
                match_str     = gig_date_match.first

                match_str     = match_str.split("2008").first + "2008" if match_str.match('2008')
                match_str     = match_str.split("2009").first + "2009" if match_str.match('2009')
                match_str     = match_str.split("2010").first + "2010" if match_str.match('2010')
                match_str     = match_str.split("2011").first + "2011" if match_str.match('2011')
                match_str     = match_str.split("2012").first + "2012" if match_str.match('2012')
                match_str     = match_str.split("2013").first + "2013" if match_str.match('2013')
                match_str     = match_str.split("2014").first + "2014" if match_str.match('2014')
                match_str     = match_str.split("2015").first + "2015" if match_str.match('2015')
                match_str     = match_str.split("2016").first + "2016" if match_str.match('2016')
                match_str     = match_str.split("2017").first + "2017" if match_str.match('2017')
                match_str     = match_str.split("2018").first + "2018" if match_str.match('2019')

                match_str     = gig_date_match.first.split(".").first if match_str.last == '.'
                # pp match_str
                gig_date      = Chronic.parse(match_str)
                if gig_date
                  gig_date_str    = gig_date.strftime('%Y/%m/%d')
                  break
                end
              end
            end

          end # unless video exists

          puts "\t-------------------------------------------"

          if video_exists
            puts "\tExists?\t\tYes, ignoring."
          else
            puts "\tExists?\t\tNo, inserting!"

            # User ID 4 is SofarBot
            Item.create(title: "#{artist} - #{song} @ Sofar #{location}", url: video_link, user_id: 4)
          end

          # Print out to console
          puts "\tURL:\t\t#{video_link}"
          unless video_exists
            puts "\tID:\t\t#{id}"
            puts "\tartist:\t\t#{artist}"
            puts "\tsong:\t\t#{song}"
            puts "\tlocation:\t#{location}"
            puts "\tuuid:\t\t#{uuid}"
            puts "\tpub date:\t#{pub_date_str}"
            puts "\tgig date:\t#{gig_date_str}"
            puts "\twho edit:\t#{who_edit}"
            puts "\twho sound:\t#{who_sound}"
            puts "\twho video:\t#{who_video}"
          end

        end

        puts ""
      end

      # Slack.notify("sofar:yt:import[page:#{args[:pages]}] COMPLETE (Scrape video data from youtube channels, populate into 'automated video metadata' spreadsheet)")
    end

  end
end
