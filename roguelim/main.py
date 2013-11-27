from dungeon import Dungeon

def main():
	dungeon = Dungeon()
	while True:
		line = raw_input()
		print("Got " + line) 
		print(dungeon)

if __name__ == "__main__":
	main()
