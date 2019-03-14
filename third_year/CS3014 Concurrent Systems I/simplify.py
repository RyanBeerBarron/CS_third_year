
def getNumber( String, Pos ):
    line = iterationString.split(" ")
    return (int) line[1]


f = open("timing.txt", "r")
fileString = f.read()
fileList = fileString.split("\n\n\n")
fileList.pop()
for timing in fileList:
    parts = timing.split("\n\n")
    code = parts[0]
    inputs = parts[1]
    iterations = (int) parts[2].split(" ")[1]
    time = (int) parts[3].split(" ")[5]
    print(iterations)
    print(time)
    