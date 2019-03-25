import collections, re, sys

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

# For each entries in the text file, split them again to access each field
# And simplify entries with identical key by merging their value
for timing in fileList:
	parts = timing.split("\n\n\n")
	
	regex = re.search( keyRegex , parts[0])
	key = Key(regex.group(), parts[1])

	if DEBUG:
		print("The program: " + regex.group())


	# Check that the key has not been simplified already
	if key not in seenKeyList:
		seenKeyList.append(key)
		total_time = 0
		total_iterations = 0

		# Loop through the entries again, looking for entries with the same key as "key"
		for timings in fileList:
			dunno = timings.split("\n\n\n")
			regex2 = re.search( keyRegex, dunno[0] )
			otherKey = Key(regex2.group(), dunno[1])

			if DEBUG:
				print("The other program: " + regex2.group())

			# Add up the iterations and the total time (with respect to the number of iterations) 
			if otherKey[0] == key[0] and otherKey[1] == key[1]:
				iteration = int(dunno[2].split(" ")[1])
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


f.close()

newFileList = sorted(newFileList, key=lambda tup: (tup[1],tup[3]))
f = open("timing.txt", "w")
""" if sys.version_info[0] == 0 and sys.version_info[1] >= 6:
	for element in newFileList:
		f.write(f'{element[0]}\n\n\n')
		f.write(f'{element[1]}\n\n\n')
		f.write(f'Iterations: {element[2]}\n\n\n')
		f.write(f'The average time was: {int(element[3])} microseconds\n\n\n\n')

else: """
for element in newFileList:
	f.write('{}\n\n\n'.format(element[0]))
	f.write('{}\n\n\n'.format(element[1]))
	f.write('Iterations: {}\n\n\n'.format(element[2]))
	f.write('The average time was: {} microseconds\n\n\n\n'.format(int(element[3])))