$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'act_as_rankable'
ActiveRecord::Base.send ( :include, ActiveRecord::Acts::Rankable )