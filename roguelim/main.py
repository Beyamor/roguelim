from dungeon import Dungeon
import command

def main():
	dungeon = Dungeon()
	while True:
		line	= raw_input()
		result	= command.process(command.read(line), dungeon)
		print(result)
		
if __name__ == "__main__":
	main()
