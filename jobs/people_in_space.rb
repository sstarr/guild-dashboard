require 'net/http'
require 'json'

SCHEDULER.every '1h', first_in: 0 do
  http = Net::HTTP.new("www.howmanypeopleareinspacerightnow.com")
  response = http.request(Net::HTTP::Get.new("/space.json"))
  response_json = JSON.parse(response.body)

  people_in_space = response_json["number"]

  send_event('people_in_space', { current: people_in_space })
end
