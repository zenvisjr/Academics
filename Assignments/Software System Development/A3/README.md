# Q1: Expense Tracker

## Introduction:
The Expense Tracker is a simple yet comprehensive tool designed to keep track of shared expenses among multiple participants. Whether you're on a trip, sharing a flat, or just going out with friends, this tool will help you ensure that everyone pays their fair share.

## Features:
- **Add Participants**: You can add as many participants as you like to the shared expense pool.
- **Add Expenses**: Whenever someone pays for a shared expense, you can quickly and easily add the expense to the tracker.
- **Distribute Expenses**: For every expense, you can specify which participants it should be split between.
- **View Participants and Their Balances**: At any point, you can view all participants and see who owes money and who is owed money.
- **View All Expenses**: A handy feature to keep track of all the shared expenses.
- **Export Data**: The program provides an option to export all the data to a `.csv` file for further analysis or record-keeping.

## Assumptions:
1. **Non-negative Amounts**: When adding an expense, the amount entered should always be positive.
2. **Valid Participants**: When distributing an expense, ensure all specified participants are already added to the tracker.
3. **Existing Participants**: Participants cannot have the same name, and once added, a participant's name cannot be altered.
4. **Only 1 participant can pay bill at a time**: If there are multiple payer, you have to again go to option 2 to enter new payer
5. **Any number of participant**: You can add participant any number of times, uniqueness is checked
6. **Opeing `.csv` file in write mode**: At a time only information of one expense is saved, all previous entry are overwrite
7. **Participant names only consits of alphabets**: any other combination with numeric or special char will raise an error


## Edge Cases Handled:
1. **Invalid Amount**: If the amount entered is zero or negative, the program prompts the user to enter a valid amount.
2. **Non-existent Participant**: If an expense is being distributed to a participant that doesn't exist, the program alerts the user and prompts them to enter a valid participant name, same goes with payer.
3. **Participant Owing and Paying**: In cases where a participant pays for an expense but also owes money, the tool accurately reflects the amount they should get back or still owe.

## How to Run:

1. **Prerequisites**: Ensure you have Python 3 installed on your machine. If not, download and install it from [Python's official website](https://www.python.org/).

2. **Running the Program**: you can run the expense tracker with the following command:
   ```bash
   python3 2023202020_A3_Q1.py
   ```
3. **Follow the Prompts**: After running the command, follow the on-screen prompts to use the expense tracker.

# Q2: Cricket Directory 

### Description

The cricket directory is a menu-driven Python program that allows you to manage a list of cricketers. Each cricketer has the following details:

1. First Name
2. Last Name
3. Age
4. Nationality
5. Role (Batsman, Bowler, All-rounder)
6. Runs
7. Balls
8. Wickets
9. Strike Rate


### Assumptions

1. **Primary key**: A combination of "First Name" and "Last Name" is used as a unique identifier for each cricketer.
2. **All valid input**: All input data are valid and in the correct format. 
3. **Entering Role**: while entering role anywhere, it is case sensitive
4. **Printing search result**: I am printing entire dictionary of the searched result
5. **Updating field is case sensitive**: when entering the heading of the column that we want to change, it is case sensitive (age and Age will be different)
6. **All fields are necessary**: while entering a new player details, entering all fields are necessary
7. **Not striping spaces**: Assuming anything entered is with out spaces

### Edge Cases Handled

1. Handling missing or incomplete data when reading from a CSV file.
2. Handling duplicate entries in CSV file.

## How to Run:

1. **Prerequisites**: Ensure you have Python 3 installed on your machine. If not, download and install it from [Python's official website](https://www.python.org/).

2. **Install tabulate module**

```bash
pip install tabulate
```

2. **Running the Program**: you can run the expense tracker with the following command:
   ```bash
   python3 2023202020_A3_Q2.py
   ```
3. **Follow the Prompts**: After running the command, follow the on-screen prompts to use the expense tracker.



# Q3: Visualization

## Introduction:
The pie chart visualization is an extension of our `Expense Tracker` and `Cricket Directory` that 
1. provides a graphical representation of how much each participant owes or gets back by creating 2 different `Pie Chart`
2. visualizes the performance of cricketers based on their roles and strike rates using `Histogram`

### Expense Tracker Pie Chart

## Features:
- **Two Separate Charts**: 
    1. The first chart represents participants who owe money.
    2. The second chart represents participants who are owed money.
- **Interactive Legend**: The pie charts come with a legend that provides information about the total amount and lists participants with their corresponding colors on the chart.

## Assumptions:
1. **Positive and Negative Amounts**: The pie chart assumes that positive amounts indicate that a participant is owed money, while negative amounts indicate that a participant owes money.

## Edge Cases Handled:
1. **Participants with Zero Balance**: If a participant neither owes nor is owed any money, they won't be displayed in the pie chart.
2. **Legend Overlapping**: In cases where the legend might overlap with the pie chart, its location is adjusted to ensure clear visibility.

### Cricket Directory Histogram

## Features:

- **Role-Based Segregation**: 
    1. Batsmen: A separate histogram showcases the batting strike rates of players who are primarily batsmen.
    2. Bowlers: Another histogram focuses on the bowling strike rates for players who are primarily bowlers.

- **Dual Charts for All-rounders**: 
    For players who are all-rounders, two histograms are displayed side by side. 
    1. The first one represents their batting strike rate.
    2. The second one represents their bowling strike rate.


### Edge Cases Handled

1. Handling players who are only Batsmen or Bowlers.
2. Handling All-rounders by showing both batting and bowling performance.
3. Not showing Wk-Batsmen in the pie chart.

### How to Run

1. **Installing Matplotlib**: To install Matplotlib, you can use pip:

```bash
pip install matplotlib
```

2. **Running Program**: To run the program, execute the following command:

```bash
python python3 2023202020_A3_Q3.py
```



3. **Viewing the Histogram and Pie Chart**: Once executed:
* First `histogram` will we show in a new window
* close the histogram window to see a new window popup that shows `Pie Chart` of `"Owes"`
* close the Owes chart window to see a new window popup that shows `Pie Chart` of `"Gets Back"`

