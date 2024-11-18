#include <iostream>
#include <cstdlib>
#include <functional>
#include <limits>
#include <ctime>



using namespace std;

// template <typename T>
template <typename T, typename Compare = less<T>>

class SkipList 
{
public:
    #define MAX_LVL 4
    Compare comp;
    

    struct Node 
    {
        T data;
        Node** next;
    };

    int lvl;   //represents the current highest level that has any nodes in the list, initially 0 sa no nodes present
    Node* head;  // starting point of skip list initilized to default value, place from where all links generate to every level

    SkipList() 
    {
        //srand((time(NULL))); //using to get different random level in different execution
        lvl = 0;
        // head = createNode(MAX_LVL, numeric_limits<T>::lowest());
        head = createNode(MAX_LVL, T());
    }

    ~SkipList(){}


    // struct DefaultComparator 
    // {
    // bool operator()(const T& a, const T& b) const 
    // {
    //     return a < b;
    // }
    // }
    // CompType compaa; 
    

    Node* createNode(int lvl, T data) 
    {
        Node* temp = new Node;
        temp->data = data;
        //remember lvl start with 0
        temp->next = new Node*[lvl + 1];
        for (int i = 0; i <= lvl; i++) 
        {
            temp->next[i] = NULL;
        }
        return temp;
    }

    int randomLevel() 
    {
        int levDecide = 0;
        while (levDecide < MAX_LVL && rand()%2 == 1) 
        {
            levDecide++;
        }
        return levDecide;
    }


    void insert(T value) 
    {
        //storePointer is an array to store pointer to struct Node (helpful in linking elements while inserting)
        Node* storePointer[MAX_LVL + 1];
        Node* temp = head;

        for (int i=lvl; i >= 0; i--) 
        {
            while (temp->next[i] != NULL && comp(temp->next[i]->data, value)) 
            {
                temp = temp->next[i];
            }
            storePointer[i] = temp;
        }

        //temp = temp->next[0];

        if(temp == NULL || comp(temp->data, value))
        {
            int newLvl = randomLevel();
            cout<<"level: "<<newLvl<<endl;
            if (newLvl > lvl)      //node is inserting on a level that is higher than the current level with nodes
            {
                for (int i = lvl+1; i <= newLvl; i++) 
                {
                    //as there are no nodes between level+1 and newLvl so storePointer array pointers point to head node
                    storePointer[i] = head;
                }
                lvl = newLvl;
            }

            Node* fresh = createNode(newLvl, value);
            for (int i = 0; i <= newLvl; i++) 
            {
                //storePointer fresh node next pointers to whatevery next pointer of storePointer array were pointing 
                fresh->next[i] = storePointer[i]->next[i];

                //then storePointer the next pointers of storePointer array to now point to our fresh node created
                storePointer[i]->next[i] = fresh;

                //this way our node is not connected to next nodes and previous nodes (stored by storePointer array) are connected to our fresh node
            }
        }
    }

    void del(T value) 
    {
        Node* temp = head;
        Node* storePointer[MAX_LVL+1];

        for (int i=lvl; i>=0; i--) 
        {
            while (temp->next[i] != NULL && comp(temp->next[i]->data, value)
)
            {
                temp = temp->next[i];
            }
            storePointer[i] = temp;
        }
        
        temp = temp->next[0];

        // Node* prev;
        //  while(temp != NULL && temp->data == value) 
        //  {
        //     prev = temp;
        //     temp = temp->next[0];
        //  }
        //  temp = prev;

        if (temp != NULL && /*temp->data == value*/ (!comp(temp->data, value) && !comp(value, temp->data))) 
        {
            for (int i=0; i <= lvl; i++) 
            {
                if (storePointer[i]->next[i] != temp)
                    break;
                storePointer[i]->next[i] = temp->next[i];
            }
            delete temp;

            while (head->next[lvl] == NULL && lvl>0) 
            {
                lvl--;
            }
        } 
        // else 
        // {
        //     cout<<"Element not present"<<endl;
        // }
    }

    void deleteNode(T value)
    {
        int n = count_element_occurence(value);
        while(n)
        {
            del(value);
            //print();
            n--;
        }

    }

    bool search(T value) 
    {
        Node *temp = head;
        for(int i=lvl; i>=0; i--)
        {
            while(temp->next[i] != NULL && comp(temp->next[i]->data, value)
)
            {
                temp = temp->next[i];
            }
        }
        temp = temp->next[0];

        if(temp != NULL && /*temp->data == value*/ (!comp(temp->data, value) && !comp(value, temp->data))) return true;
        else return false;
    }

    int count_element_occurence(T value)
    {

        Node* temp = head;

        // while(temp->next[0] != NULL)
        // {
        //     //cout<<"entering print"<<endl;
        //     cout<<temp->next[0]->data<<" ";
        //     temp = temp->next[0];

        // }
        // cout<<endl;
        //temp = head;
       // Node* storePointer[LVL + 1];
        int k=0;
        for (int i = lvl; i >= 0; i--) 
        {
            while (temp->next[i] != NULL && comp(temp->next[i]->data, value)
)
            {
                k++;
                temp = temp->next[i];
            }
            //storePointer[i] = temp;
        }

        

        temp = temp->next[0];
        // cout<<temp->data<<endl;
        // cout<<temp->next[0]->data<<endl;
        // cout<<temp->next[0]->next[0]->data<<endl;
        // cout<<k<<endl;


        int count=0;
        
        while(temp != NULL && /*temp->data == value*/ (!comp(temp->data, value) && !comp(value, temp->data)))
        {
            //cout<<"count entering"<<endl;
            count++;
            //cout<<count<<endl;
            temp = temp->next[0];
        }
        //cout<<"count: "<<count<<endl;

        return count;
    }

    T lower_bound(T value)
    {
        Node* temp = head;
        // if(head->next[0] == NULL)
        // {
        //     cout<<"list is empty"<<endl;
        // }
        int k=0;
        for(int i=lvl; i>=0; i--)
        {
            while(temp->next[i] != NULL && comp(temp->next[i]->data, value)
)
            {
                k++;
                temp = temp->next[i];
            }
        }if(temp->next[0] == NULL) 
        {
            return T();
        }
        else
        {
            return temp->next[0]->data;
        }
       // return temp->next[0];
        
    }

    T upper_bound(T value)
    {
        Node* temp = head;
        // if(head->next[0] == NULL)
        // {
        //     cout<<"list is empty"<<endl;
        // }
        int k=0;
        for(int i=lvl; i>=0; i--)
        {
            while(temp->next[i] != NULL && /**/(comp(temp->next[i]->data, value) || (!comp(temp->next[i]->data, value) && !comp(value, temp->next[i]->data))))
            {
                k++;
                temp = temp->next[i];
            }
        }
        //cout<<"last element: "<<temp->data<<endl;
        if(temp->next[0] == NULL) 
        {
            //cout<<"last element: "<<temp->data<<endl;
            return T();
        }
        else
        {
            return temp->next[0]->data;
        }
        
    }

    T closest_element(T value)
    {
        Node* temp = head;
        if(temp->next[0] == NULL)
        {
            return T();
        }
        for(int i=lvl; i>=0; i--)
        {
            while(temp->next[i] != NULL && comp(temp->next[i]->data, value)
)
            {
                temp = temp->next[i];
            }
        }

        T before, after;
        if(temp->next[0] == NULL)
        {
            //temp = temp->next[0];
            // cout<<"Entering null"<<endl;
            // cout<<temp->data;
            return temp->data;
        }
        else if(temp->next[0] != NULL)
        {
            if(value == temp->next[0]->data) 
            {
                // cout<<"Entering equal"<<endl;
                // cout<<temp->data<<endl;
                return temp->next[0]->data;
            }
            // else if(value<0)
            // {
            //     //cout<<"entring -ve"<<endl;
            //     return temp->next[0]->data;
            // }
            else
            {  
                before = temp->data;
                //cout<<before<<endl;
                after = temp->next[0]->data;
                //out<<after<<endl;

                T before_diff = value - before;
                //cout<<before_diff<<endl;
                T after_diff = after - value;
                //cout<<after_diff<<endl;
                if(comp(before_diff, after_diff)) return before;
                else return after;
            }
        }
    }

    void print()
    {
        Node* temp = head;

        while(temp->next[0] != NULL)
        {
            //cout<<"entering print"<<endl;
            cout<<temp->next[0]->data<<" ";
            temp = temp->next[0];

        }
        cout<<endl;
    }
};

// class Person {
// public:
//     std::string name;
//     int age;

//     Person(std::string n, int a) : name(n), age(a) {}
// };

// struct PersonComparator {
//     bool operator()(const Person& a, const Person& b) const {
//         return a.age < b.age;
//     }
// };

int main() 
{

// srand(time(NULL));
    SkipList<string> s;
    string num;
        int choice = -1;
    while (choice != 0) {
        cin >> choice;
        if (choice == 1) {
            cin>>num;
            s.insert(num);
            s.print();

        }
        else if (choice == 2) {
            cin>>num;
            s.deleteNode(num);
            s.print();
        }
        else if (choice == 3) {
            cin>>num;
            cout<< boolalpha <<s.search(num)<<endl;
            s.print();
        }
        else if (choice == 4) {
             cin>>num;
             cout << s.count_element_occurence(num) << endl;
            //s.count_element_occurence(num);
            s.print();
        }
        else if (choice == 5) {
            cin>>num;
            cout << s.lower_bound(num) << endl;
            //SkipList<int>::Node* temp = s.lower_bound(num);
            //cout<<temp->data<<endl;
            s.print();
        }
        else if (choice == 6) {
            cin>>num;
            cout << s.upper_bound(num)<< endl;
            //SkipList<int>::Node* temp = s.upper_bound(num);
            //cout<<temp->data<<endl;
            s.print();
        }
        // else if (choice == 9) {
        //     cin>>num;
        //     cout << s.closest_element(num) << endl;
        //     s.print();
            
        // }
        else if (choice == 0) {
            exit(0);
        }
        else {
            cout << "Jaldi yaha se hato" << endl;
        }
    }
// }
//     list.insert(5);
//     list.insert(9);
//     list.insert(16);
//     list.insert(200);
//     list.insert(15);
//     list.insert(15);
//     list.insert(2);
//     list.insert(13);
//     list.insert(15);
//     cout << "Searching: " << list.search(22) << endl;
//     list.deleteNode(20);
//     cout << "Searching: " << list.search(20) << endl;  
//     cout << "Searching: " << list.search(13) << endl;  
//     list.count_element_occurence(15);
//     cout<<list.lower_bound(15)->data<<endl;
//     cout<<list.upper_bound(15)->data<<endl;
//     cout<<list.closest_element(201)<<endl;

    // list.insert(5.5);
    // list.insert(9.2);
    // list.insert(16.88);
    // list.insert(200.56);
    // list.insert(15.5);
    // list.insert(15.5);
    // list.insert(2.12);
    // list.insert(13.33);
    // list.insert(15.5);
    // cout << "Searching: " << list.search(200.56) << endl;  // Added print for search result
    // list.deleteNode(9.2);
    // cout << "Searching: " << list.search(9.2) << endl;  // Added print for search result
    // cout << "Searching: " << list.search(2.12) << endl;  // Added print for search result
    // list.count_element_occurence(15.5);
    // cout<<list.lower_bound(15.5)->data<<endl;
    // cout<<list.upper_bound(15.5)->data<<endl;
    // cout<<list.closest_element(201.56)<<endl;

    // list.insert("hello");
    // list.insert("zeta");
    // list.insert("yoo my name");
    // list.insert("hii");
    // list.insert("kaam karo yrr");
    // list.insert("kaam karo yrr");
    // list.insert("beta batao");
    // list.insert("rom rom bhaiyo");
    // list.insert("kaam karo yrr");
    // cout << "Searching: " << list.search("rom rom bhaiyo") << endl;  // Added print for search result
    // list.deleteNode("beta batao");
    // cout << "Searching: " << list.search("beta batao") << endl;  // Added print for search result
    // cout << "Searching: " << list.search("hii") << endl;  // Added print for search result
    // list.count_element_occurence("kaam karo yrr");
    // cout<<list.lower_bound("kaam karo yrr")->data<<endl;
    // cout<<list.upper_bound("kaam karo yrr")->data<<endl;
   // cout<<list.closest_element("beta batao")<<endl;

    return 0;
}
