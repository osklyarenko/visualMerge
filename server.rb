#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'
require 'active_record' 

load 'visualMerge.rb'

get '/' do
	File.read("public/index.html")  
end

get '/api/files_list' do
	content_type :json

	app = VisualMerge.new ['show']	
	app.perform_action[:documents].to_json
end