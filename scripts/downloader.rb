#! /usr/bin/env ruby

#Download resources from http/bt etc

require 'net/http'

def start_task(url)
    print `wget #{url}`
end

if __FILE__ == $0
    start_task('http://www.baidu.com/index.html')
end
