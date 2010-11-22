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
              named_scope name.pluralize.downcase.gsub(/\s/, '_'), :conditions => "#{self.name.downcase.pluralize}.#{self.score_source.to_s} >= #{value}"
            end

            self.class_eval <<-RUBY
              def #{name.singularize.tableize.to_s}?
                self.#{self.score_source.to_s} >= #{value}
              end
              
              def recently_reached_#{name.singularize.to_s}_level?
                self.#{self.score_source.to_s}_changed? && self.#{self.score_source.to_s} > #{value} && self.#{self.score_source.to_s}_was < #{value}
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
        
        def recently_reached_new_level?
          # Do not detect anything if the object isn't dirty
          return false unless self.changed? && self.send(self.score_source.to_s + '_changed?')
          
          rank_reached = self.ranks.detect do |name, value|
            self.send(self.score_source.to_s + '_was') < value && self.send(self.score_source) >= value
          end
          
          if rank_reached.nil?
            false
          else
            rank_reached[0]
          end
        end
        
      end
      
    end
  end
end