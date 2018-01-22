import re
import sys

def get_cost(filename):
    """Get the target cost."""
    file = open(filename, "r")
    data = file.read()
    line = data.split('\n')[0]
    file.close()
    match = get_cost.regex.search(line)
    dollars = int(match.group('dollars'))
    cents = int(match.group('cents'))
    return dollars * 100 + cents

get_cost.regex = re.compile(r"\$(?P<dollars>[0-9]*)\.(?P<cents>[0-9]*)")


def generate_menu(filename):
    """Convert a file into a dictionary where the key is the menu item name, and the value is the cost (in cents)."""
    menu = {}

    file = open(filename, "r")
    data = file.read()
    lines = data.split('\n')[1:]
    file.close()

    for line in lines:
        match = generate_menu.regex.search(line)
        if match == None:
            if line != "":
                print "Didn't match %s" % line
        else:
            food = match.group('food')
            dollars = int(match.group('dollars'))
            cents = int(match.group('cents'))
            menu[match.group('food')] = dollars * 100 + cents
    return menu

generate_menu.regex = re.compile(r"(?P<food>.*),\$(?P<dollars>[0-9]*)\.(?P<cents>[0-9]*)$")


def generate_order_max(menu, cost):
    """Generate the maximum number of each /individual/ item that may be purchased on the budget specified.  Returns an object where the key is the menu item name, and the value is the number of that item which can be purchased."""
    order_max = {}
    for m in menu.keys():
        order_max[m] = int(cost / menu[m])
    return order_max

def create_order(menu):
    """Create an order (which we'll iterate over) with the key being the item name, and the value being the number to purchase."""
    ret = {}
    for k in menu.keys():
        ret[k] = 0
    return ret

def step_order(iter, order_max):
    """Increment a single item by one on each step.  If that goes above order_max, set that item to zero and increment the next item.  Return True if there's more to search, or False if there isn't."""
    for x in iter.keys():
        iter[x] += 1
        if iter[x] > order_max[x]:
            iter[x] = 0
        else:
            return True # keep going
    return False # stop

def check_items(menu, order):
    """Total up the order.  Returns the cost (in cents)"""
    cost = 0
    for k in order.keys():
        cost += menu[k] * order[k]
    return cost

def brute_force(menu, order_max, cost):
    """Check all possible orders, and return the first match."""
    iter = create_order(menu)
    while True:
        if check_items(menu, iter) == cost:
            return iter
        if not step_order(iter, order_max):
            break
    return None

def main(filename):
    """If we have parameters, do the whole thing..."""
    cost = get_cost(filename)
    menu = generate_menu(filename)
    order_max = generate_order_max(menu, cost)
    result = brute_force(menu, order_max, cost)
    if result == None:
        print "Didn't find any results"
        exit(1)

    for x in result.keys():
        if result[x] != 0:
            print "%i x %s" % (result[x], x)
    print "Cost: %i" % check_items(menu, result)

if len(sys.argv) != 2:
    print "Usage: %s filename" % sys.argv[0]
    print "BTW - I'm on to you... http://xkcd.com/287/"
    exit(1)
filename = sys.argv[1]

main(filename)

