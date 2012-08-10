def run
  filepath = check_arguments
  target, menu = read_menu filepath
  solutions = find_solutions target, menu

  # pretty print the menu and solutions
  print_menu menu
  print_solutions solutions, menu

  return solutions
end

def find_solutions target, menu
  # check each permutation (combo) of items to find a match
  # if a permuation has been reached before do not re-check permuations reachable from it
  # if the total cost of a permutation is greater than the target, stop permutating off it
  # if the total cost of a permutation is equal to the target, solution found
  # if the total cost of a permuation is less than the target, check permutations reachable from it
  solutions = []
  brain = []

  # a combo represents a combination of items
  combos = initialize_combos menu
  while not combos.empty?
    # remove a combo once its been checked, add it to the brain so it doesn't get checked again
    combo, combo_price = combos.shift
    brain << combo
  
    # permute the current combo by adding a new item to it
    menu.each_with_index do |menu_item, index|
      item, price = menu_item
      next_combo = combo.dup
      
      next_combo[index] += 1
      
      if brain.include? next_combo
        # permutation already checked
        next
      else
        # not checked yet, memoize and compute price
        brain << next_combo
        next_combo_price = combo_price + price
        
        if next_combo_price == target
          solutions << next_combo
        elsif next_combo_price < target
          combos[next_combo] = next_combo_price    
        end

      end
    end
  end
  return solutions
end

def check_arguments
  # ensure the user has entered a filepath
  if ARGV.length == 0
    puts "Usage: ruby menu.rb \"file/path/to/menu.txt\""
    exit
  else
    return ARGV.first
  end
end

def str_to_money str
  (str||"0").gsub("$","").to_f
end

def money_to_str money
  format("$%.2f",money)
end

def read_menu filepath
  # import the menu text into a dictionary structure
  target = 0  
  menu = {}

  # read file and close it
  file = File.new(filepath, "r")
  text = file.read
  file.close

  line_number = 0
  text.each_line do |line|
    line_number +=1
    if (line_number == 1)
      # first line of file is always the target value
      target = str_to_money(line)
    else
      # remaining files are formatted as <menu item>,$<cost>
      item, price = line.split(",")
      menu[item] = str_to_money(price)
    end
  end
  return target, menu
end

def initialize_combos menu
  # create the base combo of 0 of each item
  combos = {}
  base = menu.map{0}
  combos[base] = 0
  return combos
end

def print_solutions solutions, menu
  # pretty print method for solutions
  if solutions.empty?
    puts "No solutions."
  else
    solutions.each_with_index do |solution, solution_index|
      puts "Solution #{solution_index}"
      menu.each_with_index do |menu_item, index|
        item, price = menu_item
        count = solution[index]
        puts " -#{count.to_s.rjust(3)} x #{item.ljust(30)} = #{money_to_str(count * price).rjust(7)}"
      end
      puts ""
    end
    
  end
end

def print_menu menu
  # pretty print method
  puts "\n=========================================="
  puts "|                                        |"
  puts "|              ~~ MENU ~~                |"
  puts "|                                        |"
  menu.each do |item, price|
    puts "|   #{item.ljust(25)} - #{money_to_str(price).rjust(7)}  |"
  end
  puts "|                                        |"
  puts "==========================================\n\n"
end

run();
