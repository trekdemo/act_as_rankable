module ActiveRecord
  module Acts #:nodoc:
    module Rankable #:nodoc:
      
      def self.included(base)
        base.extend(ClassMethods)
      end
    
	    module ClassMethods
	      def act_as_rankable( opts = {} )
          opts.symbolize_keys!
          
          class_inheritable_accessor :score_source, :ranks
          
          self.score_source = opts.delete( :source ) || :score
          self.ranks = opts[:ranks]
          
          opts[:ranks].each_pair do |name, value|
            self.class_eval do
              named_scope name.pluralize, :conditions => "#{self.name.downcase.pluralize}.#{self.score_source.to_s} >= #{value}"
            end

            self.class_eval <<-RUBY
              def #{name.singularize.to_s}?
                self.#{self.score_source.to_s} >= #{value}
              end
            RUBY
          end
          
          include ActiveRecord::Acts::Rankable::InstanceMethods
        end
	    end
			
			module InstanceMethods
			  
		    def rank
		      score = self.send(self.score_source)
			    self.ranks.select { |name, value| name if value <= score }.sort {|a,b| a[1]<=>b[1]}.last[0]
			  end
		  end
		  
    end
  end
end