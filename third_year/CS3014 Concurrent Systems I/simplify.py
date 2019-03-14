import collections

Part = collections.namedtuple("Part", "foo inputs iterations time")
Key = collections.namedtuple("Key", "foo inputs")

DEBUG = False

f = open("timing.txt", "r")
fileString = f.read()
fileList = fileString.split("\n\n\n")
fileList.pop()

newFileList = []
seenKeyList = []

if DEBUG:
	print(f"Whole file is:\n{f.read()}")

for timing in fileList:
	parts = timing.split("\n\n")
	key = Key(parts[0], parts[1])

	if DEBUG:
		print(f"The key is:\n{key}")

	if key not in seenKeyList:
		seenKeyList.append(key)
		total_time = 0
		total_iterations = 0
		for timings in fileList:
			dunno = timings.split("\n\n")
			otherKey = Key(dunno[0], dunno[1])
			
			if DEBUG:
				print(f"The other key is:\n{otherKey}")
			
			if otherKey == key:
				iteration = int(dunno[2].split(" ")[1])

				if DEBUG:
					print(f"The number of iterations of other key is:\n{iteration}")

				total_time = total_time + (iteration * int(dunno[3].split(" ")[5]))
				total_iterations = total_iterations + iteration
			else:
				pass
		try:			
			average_time = total_time / total_iterations
			part = Part(parts[0], parts[1], total_iterations, average_time)
			newFileList.append(part)
		except ZeroDivisionError:
			print("Error with the number of iterations, skipping that entry")
	else:
		pass

if DEBUG:
	for element in newFileList:
		print(f'0:\n{element[0]}\n1:\n{element[1]}\n2:\n{element[2]}\n3:\n{element[3]}')

f.close()

f = open("timing.txt", "w")

for element in newFileList:
	f.write(f'{element[0]}\n\n')
	f.write(f'{element[1]}\n\n')
	f.write(f'Iterations: {element[2]}\n\n')
	f.write(f'Time was: Team conv time: {int(element[3])} microseconds\n\n\n')