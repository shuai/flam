#! /usr/bin/env ruby

require "common.rb"
require "models.rb"
require "rubygems"
require "json"
require "net/http.rb"

class Torrent
    attr_accessor :FileName, :Status, :Hash, :Msg

    def initialize(json)
        @Hash = json[0]
        @FileName = json[2]
        @Msg = json[21]

        status_code = json[1]
        @Status = "unknown"
        if status_code & 16
            @Status = "error"
        elsif json[4] == "1000"
            @Status = "done"
        end
    end

    #delete torrent from utorrent
    def delete
        utorrent.action("action=remove", @Hash)
    end
end

class UTorrent
    def initialize
        login
    end

    def action(action,hash)
        body = ""
        try_again = true
        while true
            Net::HTTP.start(Utorrent_srv, Utorrent_port) {|http|
                req_str = "/gui/?#{action}&token=#{@token}"
                if !hash.nil?
                    req_str += "&hash=#{hash}"
                end
                
                dbg("Perform action: #{req_str}\n")
                
                req = Net::HTTP::Get.new(req_str)
                req.basic_auth Utorrent_user, Utorrent_psw
                req["Cookie"] = "GUID=#{@guid}"
                response = http.request(req)

                if response.code != '200'
                    if try_again
                        try_again = false
                        dbg("Action failed, code:#{response.code}, msg:#{response.body}. try logging in again\n")
                        next
                    else
                        raise "Response code is #{response.code}, body: #{response.body}"
                    end
                end
                
                body = response.body
            }
            break
        end
        
        return body
    end

    def login
        dbg("Logging in to utorrent service\n")
        Net::HTTP.start(Utorrent_srv, Utorrent_port) {|http|
            req = Net::HTTP::Get.new('/gui/token.html')
            req.basic_auth Utorrent_user, Utorrent_psw
            response = http.request(req)

            #token
            token_page = response.body
            ret = /<div.*id=\'token\'.*>(.*)<\/div>/m.match token_page
            if ret.nil?
                raise "Failed to get token, response: #{token_page}"
            end
            @token = ret[1]


             #Get the cookie
            cookie = /GUID=(.*);/m.match response["Set-Cookie"]
            if cookie.nil?
                raise "Failed to get cookie"
            end
            @guid = cookie[1]
        }
        dbg("Token: #{@token}\nGUID:#{@guid}\n")
    end

    def get_torrents
        torrents = []
        response = action("list=1",nil)

        if response.nil? or response == ""
            return torrents
        end
        
        obj = JSON response
        obj["torrents"].each do |t|
            torrents << Torrent.new(t)
        end  

        return torrents   
    end
end

utorrent = UTorrent.new

if __FILE__ == $0

    while true
        torrents = utorrent.get_torrents
        torrents.each do |t|
        
            file = File.join(Incoming, t.FileName)
            
            if t.Status != "done"
                dbg("File not complete:#{file}")
                next
            end
            

           
            dbg("New complete file: #{file}\n")
            if File.exist? file
                task = PackageTask.new(:location => File.join(Incoming, t.FileName))
                if task.save
                    t.delete
                else
                    dbg("Failed to write to database")
                end
            else
                dbg("file doesn't exist\n")
            end                
        end

        print "Idling...\n"
        sleep(10)
    end
end
