require 'config'

retweets = []
# First, we get the retweets
VCR.use_cassette('retweets', record: :new_episodes) do
  retweets = Twitter::Client.new.retweets(302170870359662592, count: 100)
end

# Then, we sort them by date

retweets.sort_by!(&:created_at)

# Now we get the followers of each retweeter so we can make a first approximation of which path the tweet may have followed
retweeter_ids = retweets.map{|t| t[:user][:id]}
retweeter_ids << retweets.first[:retweeted_status][:user][:id]

retweeter_followers = {}

VCR.use_cassette('followers', record: :new_episodes) do
  retweeter_ids.each_with_index do |retweeter_id, i |

    pending = true
    while pending
      begin
        followers = Twitter.follower_ids(retweeter_id).to_a
        retweeter_followers[retweeter_id] = followers & retweeter_ids
        pending = false
      rescue Exception => e
        puts e.message
        sleep(60)
      end
    end


  end
end

puts retweets.map{|t| [t[:created_at], t[:user][:id], t[:user][:screen_name], retweeter_followers[t[:user][:id]].inspect].join("\t")}.join("\n")
