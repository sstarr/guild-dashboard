require 'net/http'
require 'json'

SCHEDULER.every '2m', first_in: 0 do
  checkins_url = URI("https://spaces.nexudus.com/api/Spaces/Checkins?size=100")
  checkins_req = Net::HTTP::Get.new(checkins_url)
  checkins_req.basic_auth ENV['SPACES_USER'], ENV['SPACES_PASS']
  results = Net::HTTP.start(checkins_url.hostname, 80) { |http| http.request(checkins_req) }
  json_results = JSON.parse(results.body)
  people_checked_in = json_results["Records"].select { |c| c["ToTime"] == nil }.count

  send_event('people_checked_in', { current: people_checked_in })
end
