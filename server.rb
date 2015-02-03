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

	unit = params[:unit]
	count = params[:count]

	app = VisualMerge.new ['show']	
	document = app.api_files_changed_since count.to_i.days.ago.beginning_of_day

	document.to_json
end