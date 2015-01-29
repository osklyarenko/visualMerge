#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'active_record' 

load 'visualMerge.rb'

get '/' do
	File.read("public/index.html")  
end

get '/show' do
	app = VisualMerge.new ['show']
	
	app.perform_action
end