#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'active_support/core_ext/time'

Time.zone = "London"
events = Array.new

SCHEDULER.every '10m', :first_in => 0 do |job|
  events_url = URI("https://spaces.nexudus.com/api/content/calendarevents?From_CalendarEvent_StartDate=#{Date.today.to_s}&size=2&orderBy=StartDate&dir=Ascending")
  events_req = Net::HTTP::Get.new(events_url)
  events_req.basic_auth ENV['SPACES_USER'], ENV['SPACES_PASS']
  results = Net::HTTP.start(events_url.hostname, 80) { |http| http.request(events_req) }

  events = Array.new

  JSON.parse(results.body)["Records"].each do |event|
    events.push({
      calendar: "Events",
      title: event["Name"],
      body: "",
      when_start: DateTime.iso8601(event["StartDate"]).to_s,
      when_end: DateTime.iso8601(event["EndDate"]).to_s,
      when_start_raw: DateTime.iso8601(event["StartDate"]).to_time.to_i,
      when_end_raw: DateTime.iso8601(event["EndDate"]).to_time.to_i
    })
  end

  send_event('calendar_events', { events: events })
end

SCHEDULER.every '1m', :first_in => 0 do |job|
  events_tmp = Array.new(events)
  events_tmp.delete_if{|event| DateTime.now().to_time.to_i>=event[:when_end_raw]}

  if events_tmp.count != events.count
    events = events_tmp
    send_event('calendar_events', { events: events })
  end
end
