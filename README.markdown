# ActAsRankable

Simple plugin for handling rankings, and points on a model.


# Example

    class User < ActiveRecord::Base
      act_as_rankable :score_source => :score, :ranks => { :noob => 100, :expert => 500 }
    end
    
    user = User.new ( :score => 666 )
    
    user.rank           # => "expert"
    User.first.expert?  # => true
    User.experts        # => ActiveRecord collection of expert users
    

You can use the following functions for example in observers:

    class UserObserver < ActiveRecord::Observer

      def before_save( user )
        if user.recently_reached_new_level?
          UserMailer.deliver_reached_new_level( user )
        end
      end
      
    model.recently_reached_new_level?            # => false or name of rank
    model.recently_reached_<rank_name>_level?    # => true or false

Copyright (c) 2010 Sulymosi Gergo, released under the MIT license
