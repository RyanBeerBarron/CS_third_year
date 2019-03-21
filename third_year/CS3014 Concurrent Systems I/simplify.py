import collections, re

Part = collections.namedtuple("Part", "foo inputs iterations time")
Key = collections.namedtuple("Key", "foo inputs")

DEBUG = False

# Open the file and split it in a list of entries made up of the program and its input as the key and
# the number of time it was runned with the average time as the value
f = open("timing.txt", "r")
fileString = f.read()
fileList = fileString.split("\n\n\n\n")
fileList.pop()

newFileList = []
seenKeyList = []
keyRegex = "void\ team_conv(.|\n)*sum;"
if DEBUG:
	print(f"Whole file is:\n{f.read()}")

# For each entries in the text file, split them again to access each field
# And simplify entries with identical key by merging their value
for timing in fileList:
	parts = timing.split("\n\n\n")
	if DEBUG:
		print(f"Current program being searched for {parts[0]}")

	regex = re.search( keyRegex , parts[0])
	key = Key(regex.group(), parts[1])

	if DEBUG:
		print(f"The key is:\n{key}")

	# Check that the key has not been simplified already
	if key not in seenKeyList:
		seenKeyList.append(key)
		total_time = 0
		total_iterations = 0

		# Loop through the entries again, looking for entries with the same key as "key"
		for timings in fileList:
			dunno = timings.split("\n\n\n")
			regex2 = re.search( keyRegex, parts[0] )
			otherKey = Key(regex2.group(), dunno[1])
			
			if DEBUG:
				print(f"The other key is:\n{otherKey}")
			
			# Add up the iterations and the total time ( with respect to the number of iterations) 
			if otherKey == key:
				iteration = int(dunno[2].split(" ")[1])

				if DEBUG:
					print(f"The number of iterations of other key is:\n{iteration}")

				total_time = total_time + (iteration * int(dunno[3].split(" ")[4]))
				total_iterations = total_iterations + iteration
			else:
				pass
		# Find the new average time and add that new entry to the list for the new file
		try:			
			average_time = total_time / total_iterations
			part = Part(regex.group(), parts[1], total_iterations, average_time)
			newFileList.append(part)
		except ZeroDivisionError:
			print("Error with the number of iterations, skipping that entry")
	else:
		pass

if DEBUG:
	for element in newFileList:
		print(f'0:\n{element[0]}\n1:\n{element[1]}\n2:\n{element[2]}\n3:\n{element[3]}')

f.close()

newFileList = sorted(newFileList, key=lambda tup: (tup[0],tup[1],tup[2]))

f = open("timing.txt", "w")
for element in newFileList:
	f.write(f'{element[0]}\n\n\n')
	f.write(f'{element[1]}\n\n\n')
	f.write(f'Iterations: {element[2]}\n\n\n')
	f.write(f'The average time was: {int(element[3])} microseconds\n\n\n\n')