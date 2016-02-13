require 'milkman'
require 'json'
require 'rufus-scheduler'

# milkman configuration

api_key = ENV['API_KEY']
shared_secret = ENV['SHARED_SECRET']
auth_token = ENV['AUTH_TOKEN']

scheduler = Rufus::Scheduler.new



# Postpone incomplete tasks due before today not marked for autocomplete

scheduler.every ENV['FREQUENCY'] do

  client = Milkman::Client.new api_key: api_key, shared_secret: shared_secret, auth_token: auth_token


  filter = 'status:incomplete AND dueBefore:today AND NOT tag:autocomplete'
  date_format = "%m/%d/%Y"
  sort_by = "date"
  max_items = 8

  timeline = JSON.parse(client.get "rtm.timelines.create")["rsp"]["timeline"]

  response = client.get "rtm.tasks.getList", filter: filter

  tasks = JSON.parse(response)["rsp"]["tasks"]["list"]
  if response
    tasks = JSON.parse(response)["rsp"]["tasks"]["list"].each_with_object([]) do |list, items|
      list_id = list["id"]
      [list["taskseries"]].flatten.each do |task|
        begin
          items << {
              name: task["name"],
              date: task["task"]["due"],
              priority: task["task"]["priority"],
              formatted_date: DateTime.parse(task["task"]["due"]).strftime(date_format),
              id: task["task"]["id"],
              taskseries: task["id"],
              list_id: list_id,
              source: "main"
          }
        rescue
          n = task["name"]
          series = task["taskseries"]["id"]
          task["task"].each do |d|
            items << {
                name: n,
                date: d["due"],
                priority: d["priority"],
                formatted_date: DateTime.parse(d["due"]).strftime(date_format),
                id: d["id"],
                taskseries: series,
                list_id: list_id,
                source: "rescued"
            }
          end
        end
      end
    end.sort_by { |task| task[sort_by.to_sym] }

    tasks.each do |i|
      puts "#{i[:name]} #{i[:date]} ID: #{i[:id]} Series: #{i[:taskseries]} Source: #{i[:source]} List: #{i[:list_id]}"
      client.get "rtm.tasks.postpone", timeline: timeline, list_id: i[:list_id], taskseries_id: i[:taskseries], task_id: i[:id]

      new_priority = "N"
      case i[:priority]
        when "N"
          new_priority = "3"
        when "3"
          new_priority = "2"
        else
          new_priority = "1"
      end

      unless i[:priority] == new_priority
        puts new_priority
        client.get "rtm.tasks.setPriority", timeline: timeline, list_id: i[:list_id], taskseries_id: i[:taskseries], task_id: i[:id], priority: new_priority
      end
    end
  end
end



# Postpone incomplete tasks due before now marked for autocomplete


scheduler.every ENV['FREQUENCY'] do

  client = Milkman::Client.new api_key: api_key, shared_secret: shared_secret, auth_token: auth_token

# widget configuration


  filter = 'status:incomplete AND dueBefore:now AND tag:autocomplete'
  date_format = "%m/%d/%Y"
  sort_by = "date"
  max_items = 8

  timeline = JSON.parse(client.get "rtm.timelines.create")["rsp"]["timeline"]

  response = client.get "rtm.tasks.getList", filter: filter

  tasks = JSON.parse(response)["rsp"]["tasks"]["list"]
  if response
    tasks = JSON.parse(response)["rsp"]["tasks"]["list"].each_with_object([]) do |list, items|
      list_id = list["id"]
      [list["taskseries"]].flatten.each do |task|
        begin
          items << {
              name: task["name"],
              date: task["task"]["due"],
              priority: task["task"]["priority"],
              formatted_date: DateTime.parse(task["task"]["due"]).strftime(date_format),
              id: task["task"]["id"],
              taskseries: task["id"],
              list_id: list_id,
              source: "main"
          }
        rescue
          n = task["name"]
          series = task["taskseries"]["id"]
          task["task"].each do |d|
            items << {
                name: n,
                date: d["due"],
                priority: d["priority"],
                formatted_date: DateTime.parse(d["due"]).strftime(date_format),
                id: d["id"],
                taskseries: series,
                list_id: list_id,
                source: "rescued"
            }
          end
        end
      end
    end.sort_by { |task| task[sort_by.to_sym] }

    tasks.each do |i|
      puts "#{i[:name]} #{i[:date]} ID: #{i[:id]} Series: #{i[:taskseries]} Source: #{i[:source]} List: #{i[:list_id]}"
      client.get "rtm.tasks.complete", timeline: timeline, list_id: i[:list_id], taskseries_id: i[:taskseries], task_id: i[:id]
    end
  end
end

scheduler.join
