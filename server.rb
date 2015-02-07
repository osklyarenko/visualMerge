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

def calc_since(unit, count)	
	case unit
	when :day
		count.to_i.days.ago.beginning_of_day
	when :hour
		count.to_i.hours.ago
	when :week
		count.to_i.weeks.ago
	end
end

get '/api/files_list' do
	content_type :json

	unit = params[:unit] || 'day'
	count = params[:count] || '1'

	app = VisualMerge.new ['show']	
	document = app.api_files_changed_since calc_since(unit.to_sym, count.to_i)

	document.to_json
end