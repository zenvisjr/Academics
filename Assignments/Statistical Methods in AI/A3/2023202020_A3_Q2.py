import csv
from tabulate import tabulate


cricketerList = []

# initilise a list of dictionary to store info of all cricketers 
cricketersInfo = []


# creating a dict to store data of a particular cricketer
cricketer = {}

validKeys = ["First Name", "Last Name", "Role", "Age", "Nationality", "Balls", "Runs", "Wickets", "first name", "last name", "role", "age", "nationality", "balls", "runs", "wickets"]

def removeDuplicate():
    alreadySeen = set()

    for player in cricketerList:
        uniqueKey = (player["First Name"], player["Last Name"])

        if uniqueKey not in alreadySeen:
            cricketersInfo.append(player)
            alreadySeen.add(uniqueKey)



def readCSV():
    # print("readCSV")
    try:
        with open('directory.csv', 'r', newline='') as cricketDirectory:
            # reading the reading from the file
            heading = cricketDirectory.readline().strip().split(', ')

            # reading the directory row 1 by 1 and make a cricketer dictionary
            for row in cricketDirectory:
                data = row.strip().split(', ')

                # once we get data for a particular cricketer, we populate cricketer dict and add it to cricketersInfo list
                cricketer = {key: None for key in heading}

                # for key, value in heading, data:
                #     cricketer[key] = value
                for key, value in zip(heading, data):
                    cricketer[key] = value


                cricketer["Age"] = int(cricketer["Age"])
                cricketer["Runs"] = int(cricketer["Runs"])
                cricketer["Balls"] = int(cricketer["Balls"])
                cricketer["Wickets"] = int(cricketer["Wickets"])
                cricketer["Strike Rate"] = float(cricketer["Strike Rate"])


                cricketerList.append(cricketer)

            removeDuplicate()
            print(cricketersInfo)

    except FileNotFoundError:
        print('File not found, initilizing an empty directory')

                    





def displayDirectory():

    if len(cricketersInfo) == 0:
        print("Directory is empty")
        return
    
    print(tabulate(cricketersInfo, headers="keys", tablefmt="pretty"))


def addEntry():
    firstName = input("Enter first name: ")
    lastName = input("Enter last name: ")
    
    for player in cricketersInfo:
        if player['First Name'] == firstName and player['Last Name'] == lastName:
            print("Cricketer already exists")
            return

    cricketer["First Name"] = firstName
    cricketer["Last Name"] = lastName



    age = int(input("Enter age: "))
    if age <= 0:
        print("Invalid age")
        return
    cricketer["Age"] = age

    nationality = input("Enter nationality: ")
    cricketer["Nationality"] = nationality

    role = input("Enter role (Batsmen, Bowler, All-rounder, Wk-Batsmen): ")
    if role != "Batsmen" and role != "Bowler" and role != "All-rounder" and role != "Wk-Batsmen":
        print("Invalid role")
        return
    cricketer["Role"] = role
    
    runs = int(input("Enter runs scored: "))
    if runs < 0:
        print("Invalid number of runs made")
        return
    cricketer["Runs"] = runs

    balls = int(input("Enter balls played: "))
    if balls < 0:
        print("Invalid number of balls played")
        return
    cricketer["Balls"] = balls

    wickets = int(input("Enter wickets taken: "))
    if wickets < 0:
        print("Invalid number of wickets taken")
        return
    cricketer["Wickets"] = wickets

    if role == "Batsmen":
        strikerate = (runs/balls)*100
    elif role == "Bowler":
        strikerate = (wickets/balls)*100
    elif role == "All-rounder":
        strikerate = max((runs/balls)*100, (wickets/balls)*100)

        
    cricketer["Strike Rate"] = strikerate


    cricketersInfo.append(cricketer)

    print("Cricketer added successfully!")
    
    

def removeEntry():
    firstName = input("Enter first name of the cricketer: ")
    lastName = input("Enter last name of the cricketer: ")

    # find the particular crickter in the list
    for player in cricketersInfo:
        if firstName.lower() == player["First Name"].lower() and lastName.lower() == player["Last Name"].lower():
            cricketersInfo.remove(player)
            print(f"Entry for {firstName} {lastName} has been deleted.")
            return
    
    print("No such entry found to delete.")

def checkAndUpdate(key, value, cricketer):

    if key not in validKeys:
        print("Invalid key entered")
        return False
    if key == "Age" and int(value) <= 0:
        print("Invalid age")
        return False
    cricketer[key] = int(value)

    if key == "Role" and value != "Batsmen" and value != "Bowler" and value != "All-rounder" and value != "Wk-Batsmen":
        print("Invalid role")
        return False
    cricketer[key] = value
    

    if key=="Runs" and (int(value) < 0 or int(value) > 100000):
        print("Invalid number of runs")
        return False
    cricketer[key] = int(value)


    if key == "Balls" and int(value) < 0:
        print("Invalid number of balls")
        return False
    cricketer[key] = int(value)

    
    if key == "Wickets" and int(value) < 0:
        print("Invalid number of wickets")
        return False
    cricketer[key] = int(value)




    # strike rate will be changed if any of balls, runs or wickets gets updated
    strikeBat = (cricketer["Runs"] / cricketer["Balls"])*100
    strikeBal = (cricketer["Wickets"] / cricketer["Balls"])*100
    if cricketer["Role"] == "Batsmen":
        cricketer["Strike Rate"] = strikeBat
    elif cricketer["Role"] == "Bowler":
        cricketer["Strike Rate"] = strikeBal
    elif cricketer["Role"] == "All-rounder":
        cricketer["Strike Rate"] = max(strikeBat, strikeBal)
    
    return True


        
    # cricketer["Strike Rate"] = strikerate


def updateExistingEntry():
    firstName = input("Enter first name of the cricketer: ")
    lastName = input("Enter last name of the cricketer: ")

    # find the particular crickter in the list
    for player in cricketersInfo:
        if firstName.lower() == player["First Name"].lower() and lastName.lower() == player["Last Name"].lower():
            n = input("Enter no of values u want to update: ")
            if not(n.isdigit()):
                print("Invalid number entered")
                continue
            n = int(n)
            count = 0
            for i in range(n):
                key = input("Enter field to be updated: ") 
                value = input("Enter new value: ")
                if key == "Balls" or key == "Runs" or key == "Wickets":
                    count = count + 1
                # updating player with new key and value
                if checkAndUpdate(key, value, player) == False:
                    return

            print(f"Entry for {firstName} {lastName} has been updated.")
            return
    print("No such entry found to update.")

            # keys = key.strip().split("\n")
            # values = value.strip().split("\n")
            # print(keys)
            # print(values)




def searchInDirectory():
    key = input("Enter key u want to search: ")
    key = key.lower()
    if key not in validKeys:
        print("Invalid key entered")
        return 
    value = input("Enter value u want to search: ")

    check = False
    for player in cricketersInfo:
        if str(player.get(key, "")).lower() == str(value).lower():
            check = True
            print(player)

    if check == False:
        print(f"No crickter found with {key} = {value}")
    
    
def writeCSV():
    with open('directory.csv', 'w', newline='') as cricketDirectory:
            # writer = csv.writer(cricketDirectory, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        if cricketersInfo:
            header = cricketersInfo[0].keys()
            formatted_header = ", ".join(header)
            cricketDirectory.write(formatted_header + "\n")


        # Write the data rows
        for player in cricketersInfo:
            row = [str(value) for key, value in player.items()]
            formatted_row = ", ".join(row)
            cricketDirectory.write(formatted_row + "\n")

        cricketDirectory.close()

    

while True:
    print("---------MENU--------")
    print("1. Reading directory CSV file")
    print("2. Display the directory on the terminal")
    print("3. Add new entry")
    print("4. Remove entry")
    print("5. Update existing entry")
    print("6. Search in the directory")
    print("7. Write data back to CSV file and EXIT")

    # taking input user choice
    choice = int(input())

    if choice == 1:
        readCSV()
    if choice == 2:
        displayDirectory()
    if choice == 3:
        addEntry()
    if choice == 4:
        removeEntry()
    if choice == 5:
        updateExistingEntry()
    if choice == 6:
        searchInDirectory()
    if choice == 7:
        writeCSV()
        break