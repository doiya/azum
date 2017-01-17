require 'net/http'
require 'uri'
require 'json'
require "rexml/document"
require './library'

def reply_message(message='')
	message = {
    type: 'text',
    text: message
  }
end

# "あずみん起きて"
def reply_confirm_start
	{
	  "type": "template",
	  "altText": "this is a confirm template",
	  "template": {
	      "type": "confirm",
	      "text": "おはよう\nイベント行きたいの？",
	      "actions": [
	          {
	            "type": "message",
	            "label": "行きたい！",
	            "text": "行きたい！"
	          },
	          {
	            "type": "message",
	            "label": "呼んだだけ",
	            "text": "呼んだだけ"
	          }
	      ]
	  }
	}
end

# "行きたい！"
def reply_botton_schedule
	{
	  "type": "template",
	  "altText": "this is a buttons template",
	  "template": {
	      "type": "buttons",
	    #  "thumbnailImageUrl": "images/question.jpg",
				"thumbnailImageUrl": "https://res.cloudinary.com/dn8dt0pep/image/upload/v1484641224/question.jpg",
	      "title": "日程決めるよ",
	      "text": "いつがいい？",
	      "actions": [
	          {
	            "type": "postback",
	            "label": "今日",
							"text": "今日",
	            "data": "今日だね"
	          },
	          {
	            "type": "postback",
	            "label": "明日",
							"text": "明日",
	            "data": "明日だね"
	          },
						{
							"type": "postback",
							"label": "週末",
							"text": "週末",
							"data": "週末だね"
						},
	          {
	            "type": "postback",
	            "label": "決まってない",
							"text": "決まってない",
	            "data": "じゃあ、今開催中のを紹介するね"
	          }
	      ]
	  }
	}
end


def reply_carousel_museums(museums)
	randoms = (0...museums.count).to_a.shuffle![0...5]
{
  "type": "template",
  "altText": "this is a carousel template",
  "template": {
      "type": "carousel",
      "columns": [
        hoge(museums[randoms[0]]),
       	hoge(museums[randoms[1]]),
       	hoge(museums[randoms[2]]),
       	hoge(museums[randoms[3]]),
       	hoge(museums[randoms[4]])
      ]
  }
}
end
def hoge(museum)
	{
		"thumbnailImageUrl": "https://example.com/bot/images/item1.jpg",
    "title": museum["title"].slice(0,40-museum["area"].size-1) + '/' + museum["area"],
	  "text": museum["body"],
	  "actions": [
      {
        "type": "uri",
		    "label": "詳しく",
	  	  "uri": museum["url"]
      },
			{
				"type": "postback",
				"label": "keep",
				"data": "keep"
			},
			{
				"type": "message",
				"label": "ここいいかも",
				"text": museum["title"] + "\nここいいかも"
			}
    ]
  }
end

def reply_template_museum(museum)
	{
	  "type": "template",
	  "altText": "this is a buttons template",
	  "template": {
	      "type": "buttons",
	      "thumbnailImageUrl": "https://example.com/bot/images/image.jpg",
	      "title": museum["title"] + ' ' + museum["area"],
	      "text": museum["body"],
	      "actions": [
	          {
	            "type": "uri",
	            "label": "詳しく",
	            "uri": museum["url"]
	          }
	      ]
	  }
	}
end

def reply_museum_datas(url = rand_genre[:url])
	uri = URI.parse(url)
	begin
	  response = Net::HTTP.start(uri.host) do |http|
	    http.get(uri.request_uri)
	  end
	  puts 'get response'
	  case response
	  when Net::HTTPSuccess
	  	doc = REXML::Document.new(response.body)
	  	array = []
	  	doc.elements.each('Events/Event') do |event|
#	  	doc.elements['Events'].each do |event|
		  	res = {}
		  	res["title"] = event.elements['Name'].text
		  	res["url"]   = event.attribute('href').to_s
		  	res["area"]  = event.elements['Venue/Area'].text
		  	res["body"]  = event.elements['Description'].text.gsub(/\n/, '').slice(0,59)
		  	array.push(res)
		 	end
		  puts array.count
	  	return array
	  when Net::HTTPRedirection
	  	puts 'warn'
	    logger.warn("Redirection: code=#{response.code} message=#{response.message}")
	  else
	  	puts 'error'
	    logger.error("HTTP ERROR: code=#{response.code} message=#{response.message}")
	  end
	rescue IOError => e
		puts e.message
	rescue JSON::ParserError => e
		puts e.message
	rescue => e
		puts e.message
	end
end

def reply_museum_data
	uri = URI.parse("http://www.tokyoartbeat.com/list/event_type_print_illustration.ja.xml")
	begin
	  response = Net::HTTP.start(uri.host) do |http|
	    http.get(uri.request_uri)
	  end
	  puts 'get response'
	  case response
	  when Net::HTTPSuccess
	  	doc = REXML::Document.new(response.body)
		  puts 'move'
	   	res = {}
		  res["title"] = doc.elements['Events/Event/Name'].text
		 	res["url"]   = doc.elements['Events/Event'].attribute('href').to_s
		 	res["area"]  = doc.elements['Events/Event/Venue/Area'].text
	  	res["body"]  = doc.elements['Events/Event/Description'].text.slice(0,60)
	  	return res
	  when Net::HTTPRedirection
	  	puts 'warn'
	    logger.warn("Redirection: code=#{response.code} message=#{response.message}")
	  else
	  	puts 'error'
	    logger.error("HTTP ERROR: code=#{response.code} message=#{response.message}")
	  end
	rescue IOError => e
		puts e.message
	rescue JSON::ParserError => e
		puts e.message
	rescue => e
		puts e.message
	end
end
