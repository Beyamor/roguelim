from dungeon import Dungeon
import command

def main():
	dungeon = Dungeon()
	print(str(dungeon))
	print
	while True:
		line	= raw_input()
		result	= command.process(command.read(line), dungeon)
		print(result)
		print
		
if __name__ == "__main__":
	main()
