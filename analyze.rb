require 'config'

retweets = []
# First, we get the retweets
VCR.use_cassette('retweets', record: :new_episodes) do
  retweets = Twitter::Client.new.retweets(302170870359662592, count: 100)
end

# Then, we sort them by date

retweets.sort_by!(&:created_at)

puts retweets.map{|t| [t[:created_at], t[:user][:screen_name]].join("\t")}.join("\n")
