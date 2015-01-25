#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'active_record' 

get '/' do
	File.read("public/index.html")  
end