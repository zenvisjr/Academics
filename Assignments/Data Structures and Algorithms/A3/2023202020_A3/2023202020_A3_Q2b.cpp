#include<iostream>
#include<vector>
#include<type_traits>
#include <cmath>
#include <functional>

using namespace std;

template<typename T1, typename T2>

class unorderedMap
{
    public:
    struct Node
    {
        T1 key;
        T2 value;
        Node* next;

        //creating a new Node will take 2 values, item and val and will store them in key and value and initilise next to nullptr
        Node(T1 k, T2 val)
        {
            key = k;
            value = val;
            next = NULL;
        }

    };

    int tableCapacity;               // size of the hash table
    int noOfElement;                       //no of element present in hash table
    Node** hashTable;              //table is a pointer to a array of pointer of type Node

    //constructor for the class
    unorderedMap()
    {
        //initially table size and initial no element is present
        tableCapacity = 100003;  //prime number just greater than 10^5  
        noOfElement = 0;
        hashTable = initiliseHashTable(tableCapacity);
    }

    Node **initiliseHashTable(int cap)
    {
        Node **temp = new Node*[cap];

        //every index of hash table is not pointing to any node
        for(int i=0; i<cap; i++)
        {
            temp[i] = NULL;
        }

        return temp;
    }

    
int hash(T1 key) 
{
    if constexpr (is_arithmetic_v<T1>) 
    {
        // Handling numeric types: int, long, float, double
        return abs(static_cast<long long>(key)) % tableCapacity;
    } 
    else if constexpr (is_same_v<T1, std::string>) 
    {
        // Handling string
        int hashValue = 0;
        for (char c : key) 
        {
            hashValue = (hashValue * 31 + c) % tableCapacity;
        }
        return hashValue;
    } 
    else if constexpr (is_same_v<T1, char>) 
    {
        // Handling char
        return (static_cast<int>(key)) % tableCapacity;
    }
    else 
    {
        // Fallback to std::hash
        return std::hash<T1>{}(key) % tableCapacity;
    }
}



    bool insert(T1 key, T2 value)
    {
        //new temp node created with key and value initilized
        Node *temp = new Node(key, value);

        //find index using hash function
        int index = hash(key);

        //node to traverse index position to find if key alredy exist
        Node *traverse = hashTable[index];

        while(traverse != NULL)
        {
            if(traverse->key == key) return false;
            traverse = traverse->next;
        }

        //inserting node at begining of the index
        temp->next = hashTable[index];
        hashTable[index] = temp;

        noOfElement++;
        return true;
    }

    bool erase(T1 key)
    {
        //find index using hash function
        int index = hash(key);

        //node to traverse index position to find if key already exist
        Node *cur = hashTable[index];
        Node *prev = NULL;

        while(cur != NULL)
        {
            if(cur->key == key) 
            {
                if(prev == NULL)
                {
                    //key found at beginning
                    hashTable[index] = cur->next;
                    noOfElement--;
                    return true;
                }
                else
                {
                    //key found at other place
                    prev->next = cur->next;
                    noOfElement--;
                    return true;
                }
                
            }
            else
            {
                prev = cur;
                cur = cur->next;
            }
        }

        //no key found at index provided by hash
        return false;
    }

    bool contains(T1 key)
    {
        int index = hash(key);
        Node *traverse = hashTable[index];
        
        while(traverse)
        {
            if(traverse->key == key) return true;
            traverse = traverse->next;
        }
        return false;
    }

        T2& operator[](T1 key)
    {
        int index = hash(key);
        Node *traverse = hashTable[index];

        while(traverse)
        {
            if(traverse->key == key) return traverse->value;
            traverse = traverse->next;
        }

        //if key not found then add new node at beginning
        Node *temp = new Node(key, T2());
        temp->next = hashTable[index];
        hashTable[index] = temp; 
        return temp->value;


    }
};

int main()
{
    long long n, k;
    cin>>n>>k;
    // int a[n] = {1, 3, 6, 0, 0, 3, 4, 2, 1};
    int a[n];
    for(long long i=0; i<n; i++)
    {
        cin>>a[i];
    }

    long long count=0, curr_sum=0;
    unorderedMap<int , int> map;
    map.insert(0, 1);

    for(long long i=0; i<n; i++)
    {
        curr_sum +=a[i];
        long long temp = curr_sum - k;

        //  cout << "i: " << i << ", curr_sum: " << curr_sum << ", temp: " << temp << endl; 

        if(map.contains(temp))
        {
            // cout << "freq of temp: " << map[temp] << endl;
            count += map[temp];
            // cout<<"count**********************************: "<<count<<endl;
        }

        if(!map.contains(curr_sum))
        {
            map.insert(curr_sum, 1);
        }
        else
        {
            map[curr_sum] +=1;
        }
    }

    cout<<count<<endl;
    return 0;
}