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
        //initially table size and no element present initially
        tableCapacity = 100003;
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

    
// int hash(T1 key) 
// {
//     if constexpr (is_arithmetic_v<T1>) 
//     {
//         // Handling numeric types: int, long, float, double
//         return abs(static_cast<long long>(key)) % tableCapacity;
//     } 
//     else if constexpr (is_same_v<T1, std::string>) 
//     {
//         // Handling string
//         int hashValue = 0;
//         for (char c : key) 
//         {
//             hashValue = (hashValue * 31 + c) % tableCapacity;
//         }
//         return hashValue;
//     } 
//     else if constexpr (is_same_v<T1, char>) 
//     {
//         // Handling char
//         return (static_cast<int>(key)) % tableCapacity;
//     }
// }



int hash(T1 key) 
{
    long long res = 0;

    if constexpr (is_integral<T1>::value == true) 
    {
        // Handling integral types: int, long
        res = key ^ (key >> 16);
    } 
    else if constexpr (is_floating_point<T1>::value == true) 
    {
        // Handling floating-point types: float, double
        // We convert the float to its bit representation for hashing
        res = *reinterpret_cast<long long*>(&key);
        res ^= (res >> 32);
    } 
    else if constexpr (is_same<T1, string>::value == true) 
    {
        // Handling string
        const int p = 31;
        const int m = 1e9 + 9;
        long long pow = 1;
        for (char c : key) {
            res = (res + (c - 'a' + 1) * pow) % m;
            pow = (pow * p) % m;
        }
    } 
    else if constexpr (std::is_same<T1, char>::value) 
    {
        // Handling char
        res = key;
    }

    int hashValue = abs(res) % tableCapacity;
    cout<<"hash value: "<<hashValue<<endl;
    return hashValue;
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

    void print()
    {
        
        for(int i=0; i<tableCapacity; i++)
        {
            Node *temp = hashTable[i];
            if (temp != nullptr)  // Only enter if the list is not empty
            {
                while(temp)
                {
                    cout<<temp->value<<" ";
                    temp = temp->next;
                }
                cout<<endl;
            }
            
        }
    }

    int size()
    {
        return noOfElement;
    }

    void clear()
    {
        noOfElement=0;
        
        //removing every element
        for(int i=0; i<tableCapacity; i++)
        {
            Node *temp = hashTable[i];
            while(temp)
            {
                Node *remove = temp;
                temp = temp->next;
                delete remove;
            }
            //making every index to null
            hashTable[i] = NULL;
        }
    }
    
    bool empty()
    {
        if(noOfElement > 0) return false;
        else return true;
    }

    vector<T1> keys()
    {
        vector<T1> v;
        for(int i=0; i<tableCapacity; i++)
        {
            Node *temp = hashTable[i];
            while(temp)
            {
                v.push_back(temp->key);
                temp = temp->next;
            }
        }

        return v;
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
    unorderedMap<int , long> map;
    int key;
    long value;
    vector<int> ans;

    // cout << boolalpha << map.insert(5, 23) << endl;
    // map.print();
    // cout << boolalpha << map.insert(27, 47) << endl;
    // map.print();
    // cout << boolalpha << map.insert(567, 56) << endl;
    // map.print();
    // cout << boolalpha << map.insert(342, 112) << endl;
    // map.print();
    // cout << boolalpha << map.insert(342, 99) << endl;
    // map.print();
    // cout << boolalpha << map.insert(761, 67) << endl;
    // map.print();
    // cout << boolalpha << map.insert(122334, 23) << endl;
    // map.print();
    // cout << boolalpha << map.insert(122334, 56) << endl;
    // map.print();
    // cout << boolalpha << map.erase(27) << endl;
    // map.print();
    // cout << boolalpha << map.erase(46) << endl;
    // map.print();
    // cout << "size: "<<map.size() << endl;
    // // map.clear();
    // cout << "size: "<<map.size() << endl;
    // cout << "key found: "<<map.contains(5) << endl;
    // cout << "key found: "<<map.contains(767) << endl;
    // cout << boolalpha << map.empty() << endl;
    // // map.clear();
    // // cout << boolalpha << map.empty() << endl;

    // vector<int> ans = map.keys();
    // for(auto i:ans)
    // {
    //     cout<<i<<" ";
    // }

    int q;
    cin>>q;
    while(q--)
    {
        int choice;
        // cout<<"Enter type of operation to perform: ";
        cin>>choice;

        if (choice == 1) {
            cin>>key>>value;
            cout << boolalpha << map.insert(key, value) << endl;
        }
        else if (choice == 2) {
            cin>>key;
            cout << boolalpha << map.erase(key) << endl;
        }
        else if (choice == 3) {
            cin>>key;
            cout << boolalpha << map.contains(key) << endl;

        }
        else if (choice == 4) {
            cin>>key;
            cout << map[key] << endl;
            // cout << map[key]++ << endl;
        }
        else if (choice == 5) {
            map.clear();
        }
        else if (choice == 6) {
            cout << map.size() << endl;
        }
        else if (choice == 7) {
            cout << boolalpha << map.empty() << endl;
        }
        else if (choice == 8) {
            ans = map.keys();
            for(auto i:ans)
            {
                cout<<i<<" ";
            }
            cout<<endl;
        }
    }
    return 0;
}







