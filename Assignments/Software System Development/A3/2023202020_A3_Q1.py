
import csv
totalAmount = 0
def printTable(name, amount, status, width):
    
    
    # Print participant name
    print("+" + "-" * (width*2+4) + "+")
    print("|" + name.center(width*2+4) + "|")
    
    # Print amount and status
    print("+" + "-" * (width*2+4) + "+")
    print("|" + str(abs(amount)).center(width + 2) + "|" + status.center(width + 1) + "|")
    
    print("+" + "-" * (width*2+4) + "+")
    print()



# initilise empty dict to store all participant of a transaction
participant = {}

# initlise a empty list to store expense details
expense = []

# infinte menu start here
while True:

    # printing menu
    print("---------MENU--------")
    print("1. Add participant")
    print("2. Add expense")
    print("3. Show all participants")
    print("4. Show all expenses")
    print("5. Exit/export")

    # taking input user choice
    choice = int(input())

    if choice == 1:
        name = input()
        if len(name) > 0:
            # split and store names in a list
            nameList = name.split(" ")
            # print(nameList)

            uniqueNames = set(nameList)
            # print(uniqueNames)
            #removing empty string from list
            uniqueNames.discard('')
            # print(uniqueNames)

            count = 0
            # checking for invalid names containing numberic or special char
            for name in uniqueNames:
                if name.isalpha() == False:
                    count += 1
                    break
            if count == 0:
                # looping over all naems in set and adding them into dict as key with balance as 0
                participant.update({name: 0 for name in uniqueNames})
                print("Participant added successfully")
                # print(participant)
            else:
                print("1 or more Invalid Name entered, Please enter valid name.")
        else:
            print("Enter atleast 1 name")
            continue
    
    elif choice == 2:

        paidBy = input("Paid by: ")
        # removing leading and trailing spaces
        paidBy = paidBy.strip()
        # checking if paid by is in participant list
        if paidBy not in participant:
            print("participant that paid the bill do not exist! Please enter valid name.")
            continue

        amount = input("Amount: ")
        # removing leading and trailing spaces
        amount = amount.strip()

        #checking if only positive numeric number is entered
        try:
            amount = float(amount)
            
        
            if amount <= 0:
                if amount == 0:
                    print("Amount must be greater than 0: Enter valid amount")
                else:
                    print("Amount cannot be negative: Enter valid amount")
                continue
        except ValueError:
            print("Invalid value entered, please enter numeric values only")
            continue
        totalAmount +=amount

        DistributedAmong = input("Distributed Among: ")

        # Create the set from the string
        distributedAmongNames = set(DistributedAmong.strip().split(" "))

        # Remove the empty string if it exists
        distributedAmongNames.discard('')

        # print(distributedAmongNames)
        # Check if any of the names are invalid
        # for name in distributedAmongNames:
        #     if name not in participant:
        #         print(f"{name} do not exist in the participant list! Please enter valid name.")
        #         continue

        # checking if spilt is between valid participant
        flag = 0
        for name in distributedAmongNames:
            if name not in participant.keys():
                print("Some participant do not exist: Enter valid participant again")
                flag = 1
        if(flag):
            continue
        
        # calculating share of each participant
        share = round(amount/len(distributedAmongNames), 3)
        # print(share)
        # checking if payer is in also distributing the total amount
        payerIsDistributed = paidBy in distributedAmongNames
        # updating participant dict to add share
        for name in distributedAmongNames:
            if name == paidBy:
                participant[paidBy] += (amount - share)  # Add back the share this person should get
                # print(participant)
            else:
                participant[name] -= share  # Deduct the share this person owes
                # print(participant)
        
        # if payer is not distributing then he will get complete amount
        if not payerIsDistributed:
            participant[paidBy] += amount
        # print(participant)

        # print(paidBy)
        # print(amount)
        # print(DistributedAmong)


    elif choice == 3:
        if len(participant) == 0:
            print('No participants')
            continue
        for name in participant.keys():
            print(name)

    elif choice == 4:
        # Determine the width of the table
        if len(participant) == 0:
            print('No participants')
            continue
        width = max(len(key) for key in participant)+9

        for name, amount in participant.items():
            if amount == 0:
                continue
            status = "Owes" if amount < 0 else "Gets Back"
            printTable(name, amount, status, width)
    
    elif choice == 5:
        with open('expenses.csv', 'w', newline='') as expenseTracker:
            writer = csv.writer(expenseTracker)
            for name, amount in participant.items():
                status = "Owes" if amount < 0 else "Gets Back"
                writer.writerow([name, amount, status])

            # writer.writerow([])   #writing a blank line
            writer.writerow([totalAmount, 0, 0])

            expenseTracker.close()
            break


    else: 
        print("Invalid input")
    













