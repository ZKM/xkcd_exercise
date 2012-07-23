#!/usr/bin/ruby

def order_for_amount(prices, amount)
  states = [].fill([[], 0], 0, amount + 1)
  (prices[0]..amount).step(5) do |intermediate_amount|
    prices.each do |price|      
      current_solution = ([].fill(price, 0, intermediate_amount / price) << states[intermediate_amount % price][0]).flatten
      current_solution_price = order_price(current_solution)
      if (intermediate_amount - states[intermediate_amount][1]) > (intermediate_amount - current_solution_price) \
        || ((states[intermediate_amount][1] == current_solution_price) && (states[intermediate_amount][0].length > current_solution.length))
        states[intermediate_amount] = [current_solution, current_solution_price]
      end
    end
  end
  states[amount]
end

def order_price(order)
  order.inject(0) {|acc, item| acc+item}
end

def print_order(menu, an_order)
  an_order[0].each {|item| puts "#{menu[item]} | $#{item/100.0}"}
  puts "-" * 8
  puts "order total: $#{an_order[1]/100.0}"
end

#all amounts are in cents
appetizers = File.open("menu.txt", 'r')
#appetizers = {  
#  215 => 'mixed fruit', 
#  275 => 'french fries', 
#  335 => 'side salad', 
#  355 => 'hot wings', 
#  420 => 'mozzarella sticks',
#  580 => 'sampler plate'
#}

order_amount = 1505 

puts "\nyour appetizers for amount not exceeding $#{order_amount/100.0}:"
print_order(appetizers, order_for_amount(appetizers.keys.sort, order_amount))