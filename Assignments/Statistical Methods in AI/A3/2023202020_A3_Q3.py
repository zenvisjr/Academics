import matplotlib.pyplot as plt
import csv
from tabulate import tabulate

def calculateExplode(myList, totalAmount):
    ratio = 0
    high = []
    # print("hy")
    # print(myList)
    for key, value in myList.items():
        # print(key, value)
        prevRatio = ratio
        ratio = max(ratio , float(value)/float(totalAmount))
        if(prevRatio == ratio):
            high.append(key)
        else:
            high = []
            high.append(key)
    
    myexplode = []
    for key, val in myList.items():
        if key in high:
            myexplode.append(0.1)
        else:
            myexplode.append(0)

    return myexplode

cricketerList = []

# initilise a list of dictionary to store info of all cricketers 
cricketersInfo = []


# creating a dict to store data of a particular cricketer
cricketer = {}

validKeys = ["First Name", "Last Name", "Role", "Age", "Nationality", "Balls", "Runs", "Wickets"]

#list to store strike rate and names of cricket players
batsmen = []
bowler = []
playerName = []


expenseList = []
ownsList = {}
# ownNameList = []
getBackList = {}
# getBackNameList = []
ownsListPositive = {}
totalAmount = 0

def plotCricket():

    # plt.bar(x, height, width=0.8, bottom=None, *, align='center', data=None, **kwargs

    # Plotting the graph for the given data
    index = range(0, 2*len(playerName), 2)  #index it is list or array of numbers that represents the position of the bars on x-axis
    barWidth = 0.50

    plt.title('Batting and Bowling Strike Rate') 
    plt.xlabel('Players')
    plt.ylabel('Strike Rate')
    
    plt.bar(index, batsmen, barWidth, align='edge', label='Batting Strike Rate', color='blue')
    # for i in index:
    plt.bar([i+barWidth for i in index], bowler, barWidth, align='edge', label='Bowling Strike Rate', color='orange')

    plt.legend(loc='upper left')
    plt.xticks([i+barWidth for i in index], playerName)
    plt.tight_layout()
    plt.show()
def removeDuplicate():
    alreadySeen = set()

    for player in cricketerList:
        uniqueKey = (player["First Name"], player["Last Name"])

        if uniqueKey not in alreadySeen:
            cricketersInfo.append(player)
            alreadySeen.add(uniqueKey)



def readCricketerCSV():
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
            # print(cricketersInfo)

    except FileNotFoundError:
        print('File not found, initilizing an empty directory')

def extractCricketerData():
    readCricketerCSV()

    # print(tabulate(cricketersInfo, headers="keys", tablefmt="pretty"))

    for cricketer in cricketersInfo:
        if cricketer["Role"] == "Batsmen":
            batsmen.append(cricketer["Strike Rate"])
            bowler.append(0)
        elif cricketer["Role"] == "Bowler":
            batsmen.append(0)
            bowler.append(cricketer["Strike Rate"])
        else:
            batsmen.append(round((cricketer["Runs"] / cricketer["Balls"])*100, 2))
            bowler.append(round((cricketer["Wickets"] / cricketer["Balls"])*100, 2))
        
        playerName.append(cricketer["First Name"])

    # print(playerName)
    # print(batsmen)
    # print(bowler)



def readExpenseCSV():
    # print("readCSV")
    try:
        with open('expenses.csv', 'r', newline='') as expenseTracker:

            # reading the directory row 1 by 1 and make a cricketer dictionary
            for row in expenseTracker:
                data = row.strip().split(',')


                expenseList.append(data)


            # print(expenseList)


    except FileNotFoundError:
        print('File not found, initilizing an empty directory')

def PlotExpenseData():
    readExpenseCSV()

    
    for name in expenseList:
        if name[2] == "Owes":
            ownsList[name[0]] = name[1]
        elif name[2] == "Gets Back":
            getBackList[name[0]] = name[1]
        else:
            totalAmount = name[0]

    # making owes value +ve
    ownsListPositive = {key: abs(float(value)) for key, value in ownsList.items()}

    # print(totalAmount)
    # print(ownsList)
    # print(ownNameList)
    # print("hy")
    # print(getBackList)
    # print(getBackNameList)
    # print(ownsListPositive)

    owesAmount = 0
    getsBackAmount = 0
    for k, v in ownsListPositive.items():
        owesAmount += float(v)
    for k, v in getBackList.items():
        getsBackAmount += float(v)

    

    plt.figure(figsize=(10, 6))
    plt.pie(ownsListPositive.values(), labels=ownsListPositive.keys(), shadow=True, explode = calculateExplode(ownsListPositive, getsBackAmount), autopct='%1.1f%%')
    plt.legend(loc='lower right', title=f"Amount = {getsBackAmount} Owes")
    plt.axis('equal')
    plt.title('Owes')
    plt.show()

    
    plt.figure(figsize=(10, 6))
    plt.pie(getBackList.values(), labels=getBackList.keys(), shadow=True, explode = calculateExplode(getBackList, getsBackAmount),  autopct='%1.1f%%')
    plt.title('Gets Back')
    plt.legend(loc='lower right', title=f"Amount = {getsBackAmount} \nGets Back")
    plt.axis('equal')
    plt.show()


extractCricketerData()
plotCricket()
PlotExpenseData()





        