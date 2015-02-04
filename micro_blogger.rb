require 'jumpstart_auth'
require 'klout'
require 'bitly'




class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
  end

def tweet(message)
   if message.length > 140
   	 puts "Warning: Tweet Not Sent!! >140 characters"
   else
     @client.update(message)
   end
end

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
      when 'q' then puts "Goodbye!"
      when 't' then tweet(parts[1..-1].join(" "))
      when 'dm' then dm(parts[1], parts[2..-1].join(" "))
      when 'spam' then spam_my_followers(parts[1..-1].join(" "))
      when 'elt' then everyones_last_tweet      
      when 's' then shorten parts[1]      
      when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))      
      else
        puts "Sorry, I don't know how to #{command}"
      end
    end # while
  end

  def dm(target, message)
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    #screen_names = @client.followers.collect { |follower| follower.screen_name }
  	if screen_names.include? target
  	  puts "Trying to send #{target} this direct message:"
      puts message 
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "Error. You can only dm users that are following you."
    end
  end

  def followers_list
    screen_names = []
    client.followers.each { |follower|  screen_names << @client.user(follower).screen_name }
    puts "screen_names = #{screen_names}"
    screen_names
  end  

  def spam_my_followers(message)
    list_of_followers = followers_list
    list_of_followers.each { |follower| dm(follower,message) }
  end

  def klout_score
    friends = @client.followers.collect{|f| @client.user(f).screen_name}
    #friends = @client.friends.collect{|f| f.screen_name}
    puts "Here are the friends"
    puts friends
    friends.each do |friend|
      identity = Klout::Identity.find_by_screen_name(friend)
      user = Klout::User.new(identity.id)
      puts "#{friend} has score #{user.score.score}"
      puts "" #Print a blank line to separate each friend
    end
  end

=begin
  def everyones_last_tweet
    friends = client.friends
    #friend = friends.first
    friends.each do |friend|
      # find each friend's last message
      # print each friend's screen_name
      # print each friend's last message
      puts "#{friend.screen_name}"
      #print "#{friend.methods}"
      #puts ""  # Just print a blank line to separate people
    end
  end
=end

  def everyones_last_tweet
    friends = []
    @client.followers.each {|follower| friends << @client.user(follower)}
    friends.sort_by {|friend| friend.screen_name.downcase}
    friends.each do |friend|
      timestamp = friend.status.created_at
      puts "#{friend.screen_name} said this on #{timestamp.strftime("%A, %b %d")}..."
      puts "#{friend.status.text}"
    end
  end

  def shorten(original_url)
    # Shortening Code
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    puts "Shortening this URL: #{original_url}"
    short_url = bitly.shorten(original_url).short_url
  end

end

puts "".ljust(140, "abcd").length
blogger = MicroBlogger.new
#blogger.tweet("MicroBlogger Initialized. Less than 140 characters.")
#blogger.tweet("".ljust(140, "abcd"))
#blogger.tweet("".ljust(148, "abcd"))
blogger.klout_score
blogger.run

