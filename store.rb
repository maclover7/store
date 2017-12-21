require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'
  gem 'colored'
end

require 'colored'

class Item < Struct.new(:description, :buyer_price, :sales_price)
end

class Store < Struct.new(:owner, :phone_number, :items)
end

class App
  attr_accessor :store

  def run
    puts 'Welcome to the Store App!'
    puts 'Please enter the store information:'.green
    puts 'Please enter the store owner:'
    STDOUT.flush
    owner = gets.chomp
    puts 'Please enter the store phone number:'
    STDOUT.flush
    phone_number = gets.chomp

    @store = Store.new(owner, phone_number, [])

    puts 'Store created successfully!'.green

    while(true) do
      command = prompt_command
      dispatch(command)
    end
  end

  def dispatch(command)
    send(command.to_sym)
  end

  def prompt_command
    puts 'Which task would you like to complete?'.yellow
    puts 'Enter add_item to add an item'
    puts 'Enter search_item to search for an item'
    puts 'Enter buy_item to buy an item'
    puts 'Enter rm_item to remove an item'
    puts 'Enter ex to exit the app'
    STDOUT.flush
    return gets.chomp
  end

  # USER INTERFACE
  protected
    def add_item
      puts 'How many items would you like to add?'.yellow
      STDOUT.flush
      num = gets.chomp.to_i

      num.times do
        puts 'Please enter the item information:'.green
        puts 'Enter the description for the item:'
        STDOUT.flush
        description = gets.chomp

        puts 'Enter the buyer price for the item:'
        STDOUT.flush
        buyer_price = gets.chomp.to_i

        puts 'Enter the sales price for the item:'
        STDOUT.flush
        sales_price = gets.chomp.to_i

        @store.items << Item.new(description, buyer_price, sales_price)
        puts 'Item added successfully!'.green
      end
    end

    def buy_item
      items = search_item

      if items.size == 0
        puts 'There are no items that matched your search criteria'.red
      end

      puts 'How many of the items would you like to buy?'.yellow
      puts "There are currently #{items.size} available.".yellow

      STDOUT.flush
      amount = gets.chomp.to_i

      remove_items = items[0...amount]
      remove_items.each do |item|
        @store.items.delete(item)
      end

      puts 'Items bought successfully'.green
    end

    def ex
      puts 'Thank you for using the Store App, goodbye.'.green
      exit 0
    end

    def rm_item
      items = search_items

      if items.size == 0
        puts 'There are no items that matched your search criteria'.red
      end

      puts 'How many of the items would you like to remove?'.yellow
      puts "There are currently #{items.size} available.".yellow

      STDOUT.flush
      amount = gets.chomp.to_i

      remove_items = items[0...amount]
      remove_items.each do |item|
        @store.items.delete(item)
      end

      puts 'Items removed successfully'.green
    end

    def search_item
      puts 'By which filed would you like to search for items?'.yellow
      puts 'Enter desc for description, bp for buyer price, or sp for sales price'.yellow
      STDOUT.flush
      search_field = gets.chomp

      # Convert back to attribute names
      if search_field == 'bp'
        search_field = 'buyer_price'
      elsif search_field == 'desc'
        search_field = 'description'
      elsif search_field == 'sp'
        search_field = 'buyer_price'
      else
        puts 'Sorry, this is an unaccepted search field. Please try again.'.red
        search_item
      end

      puts 'What would you like this field to equal?'
      STDOUT.flush
      search_field_contents = gets.chomp

      # Safely try and convert to an integer
      if (search_field == 'bp' || search_field == 'sp')
        begin
          search_field_contents = Integer(search_field_contents)
        rescue
          puts 'This is an invalid content type for the field you are trying to search by'.red
          search_item
        end
      end

      return_items = []
      @store.items.each do |item|
        if item.public_send(search_field.to_sym) == search_field_contents
          return_items << item
        end
      end

      return_items
    end
end

App.new.run
