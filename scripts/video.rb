#! /usr/bin/env ruby

require "open3.rb"

class Stream
    attr_accessor :Index, :Codec, :CodecLong, :Type, :SampleRate, :Channel, :BitPerSample, :AvgFrameRate, :StartTime, :Duration
    
end

class Video
    attr_accessor :FileName, :Format, :Title, :Duration, :Size, :Bitrate, :Author, :Copyright, :Comment, :Streams

    def parse_ini(section)
        format_values = {}
        pairs = section.split "\n"
        if !pairs.nil?
            pairs.each do |pair|
                key, value = pair.split "="
                format_values[key] = value
            end            
        end
        format_values
    end

    def initialize(filename)
        @FileName = filename

        #Not using IO.popen since this stupid ffprobe always output something to stderr
        stdin, stdout, stderr = Open3.popen3("ffprobe -show_format -show_streams #{filename}")
        output = stdout.read(10240)
        
        if output.nil?
            return
        end
        
        ret = /\[FORMAT\](.*)\[\/FORMAT\]/m.match output
        if !ret.nil?
            format_values = parse_ini ret[1]

            @Format = format_values["format_name"]
            @Duration = format_values["duration"]
            @Size = format_values["size"]
            @Bitrate = format_values["bit_rate"]
            
            @Title = format_values["TAG:title"]
            @Author = format_values["TAG:author"]
            @Copyright = format_values["TAG:copyright"]
            @Comment = format_values["TAG:comment"]
        end
        
        if @Title.nil? or @Title.size == 0
            @Title = File.split(filename)[1]
        end
        
        @Streams = []
        #streams
        ret = output.scan /\[STREAM\].*?\[\/STREAM\]/m
        ret.each do |section|
            pairs = parse_ini section
            s = Stream.new
            
            s.Index = pairs["index"]
            s.Codec = pairs["codec_name"]
            s.CodecLong = pairs["codec_long_name"]
            s.Type = pairs["codec_type"]
            s.SampleRate = pairs["sample_rate"]
            s.Channel = pairs["channels"]
            s.BitPerSample = pairs["bits_per_sample"]
            s.AvgFrameRate = pairs["avg_frame_rate"]
            s.StartTime = pairs["start_time"]
            s.Duration = pairs["duration"]
     
            @Streams << s
        end
         
    end
    
    def is_video?
        !@Bitrate.nil? and !@Duration.nil?
    end
    
    def self.is_video? (filename)
        v = Video.new filename
        puts filename, v.is_video? 
        v.is_video?
    end
end

if __FILE__ == $0
    v = Video.new "/home/shuai/Desktop/2.wmv"
    puts v.inspect
end


