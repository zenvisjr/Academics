#include<iostream>
#include<vector>
#include<type_traits>

using namespace std;

template<typename T1, typename T2>

class orderedMap
{
    public:
    struct Node
    {
        T1 key;
        T2 value;
        int height;
        Node* left;
        Node* right;

        //creating a new Node will take 2 values, item and val and will store them in key and value, initilise left and right to null and height to 1
        Node(T1 item, T2 val)
        {
            key = item;
            value = val;
            height = 0;
            left = NULL;
            right = NULL;
        }

    };

    int noOfNodes;                       //no of nodes present in AVL tree
    Node* root;                         // root node of AVL tree

    //constructor for the class
    orderedMap()
    {
        
        noOfNodes = 0;
        root = NULL;
    }

    //function to get height of a node
    int height(Node* avlNode)
    {
        if(avlNode == NULL) return 0;
        else return avlNode->height;
    }

    // function to set height of each newly added node
    void setHeight(Node* avlNode)
    {
        if(avlNode != NULL)
        {
            avlNode->height = 1 + max(height(avlNode->left), height(avlNode->right));
        }
    }

    //function for all roations LL, RR, RL, LR
    Node* LL(Node* father)
    {
        //cout<<"entering LL"<<endl;
        Node* child = father->left;
        //cout<<"entering LL-1"<<endl;
        father->left = child->right; 
        //cout<<"entering LL-2"<<endl;
        child->right = father;
       // cout<<"entering LL-3"<<endl;

        setHeight(father);
       // cout<<"entering LL-4"<<endl;
        setHeight(child);
       // cout<<"entering LL-5"<<endl;

        return child;
    }

    Node* RR(Node* father)
    {
        Node* child = father->right;
        father->right = child->left; 
        child->left = father;

        setHeight(father);
        setHeight(child);

        return child;
    }

    Node* RL(Node* father)
    {
        //cout<<"entering RL"<<endl;
        Node* child = father->right;
        //cout<<"entering RL-2"<<endl;
        father->right = LL(child); 
        //cout<<"entering RL-3"<<endl;
        // child->right = father;
        return RR(father);
    }

    Node* LR(Node* father)
    {
        Node* child = father->left;
        father->left = RR(child); 
        // child->right = father;
        return LL(father);
    }

        //function to find balance factor
    int balFactor(Node* avlNode)
    {
        //cout<<"entering calculation of balancing factor"<<endl;
        if(avlNode == NULL) return 0;
        int bf = height(avlNode->left) - height(avlNode->right);
       // cout<<"balance factor: "<<bf<<endl;
        return bf;
    }


    //function to balance AVL tree
    Node* balanceAVL(Node* avlNode)
    {
        //cout<<"entering balance avl"<<endl;
        int bf = balFactor(avlNode);
        if(bf>1)
        {
            //cout<<"entering bf>1"<<endl;
            if(balFactor(avlNode->left) > 0) avlNode = LL(avlNode);
            else avlNode = LR(avlNode);
            
        }
        else if(bf<-1)
        {
            //cout<<"entering bf<-1"<<endl;

            if(balFactor(avlNode->right) > 0) avlNode = RL(avlNode);
            
            else 
            {
                //cout<<"entering else part of bf<-1"<<endl;
                avlNode = RR(avlNode);
            }
        }
       // cout<<"leaving balance avl"<<endl;
        return avlNode;
    }

    //main function implementaion 

    bool empty()
    {
        if(noOfNodes > 0) return false;
        else return true;
    }

    int size()
    {
        return noOfNodes;
    }

    Node* actualInsert(Node* avlNode, T1 key, T2 value)
    {
        //cout<<"141"<<endl;
        if(avlNode == NULL)
        {
            //cout<<"163"<<endl;
            Node* temp = new Node(key, value);
            return temp;
        }
        if(key < avlNode->key) 
        {
            //cout<<"143"<<endl;
            avlNode->left = actualInsert(avlNode->left, key, value);
        }
        else /*if(key > avlNode->key)*/
        {
            //cout<<"149"<<endl;
            avlNode->right = actualInsert(avlNode->right, key, value);
        }
        // else
        // {
        //     return avlNode;
        // }

        setHeight(avlNode);
        //cout<<"154"<<endl;
        avlNode = balanceAVL(avlNode);
        //noOfNodes++;
        return avlNode;
        
    }

    bool insert(T1 key, T2 value)
    {
        //cout<<"159"<<endl;
        
        if(root == NULL)
        {
           // cout<<"163"<<endl;
            Node* avlNode = new Node(key, value);
            root = avlNode;
            noOfNodes++;
            return true;
        }

        if(contains(key) == true)
        {
            return false;
        }
        else
        {
            //cout<<"175"<<endl;
            root = actualInsert(root, key, value);
            //cout<<"177"<<endl;
             noOfNodes++;
            return true;
        }
        
        
    }

    bool actualContains(Node* avlNode, T1 key)
    {
        // cout<<"181"<<endl;
        if(avlNode == NULL) return false;
        else if(key == avlNode->key) return true;
        else if(key < avlNode->key) return actualContains(avlNode->left, key);
        // else if(key > avlNode->key) return actualContains(avlNode->right, key);
        else return actualContains(avlNode->right, key);
        // cout<<"186"<<endl;
        return false;
    }
    bool contains(T1 key)
    {
        // if(key == root->key) return true;
        // cout<<"192"<<endl;
        return actualContains(root, key);
    }

    Node* actualErase(Node* avlNode, T1 key)
    {
        if(avlNode == NULL) return avlNode;
        else if(key < avlNode->key) avlNode->left =  actualErase(avlNode->left, key);
        else if(key > avlNode->key) avlNode->right =  actualErase(avlNode->right, key);
        else
        {
            //key = avlNode->key, we have 3 cases

            //case 1: it is a leaf node
            if(avlNode->left == NULL && avlNode->right ==NULL)
            {
                delete avlNode;
                avlNode = NULL;
            }

            //case 2.1: node with 1 left child
            else if(avlNode->right == NULL)
            {
                Node* temp = avlNode->left;
                delete avlNode;
                avlNode = temp;

            }
            //case 2.1: node with 1 right child
            else if(avlNode->left == NULL)
            {
                Node* temp = avlNode->right;
                delete avlNode;
                avlNode = temp;
            }
            else
            //finding inorder predecessor
            {
                Node* temp;
                temp = avlNode->left;
                while(temp->left != NULL)
                {
                    temp = temp->right;
                }
                avlNode->value = temp->value;
                avlNode->key = temp->key;

               avlNode->left = actualErase(avlNode->left, temp->key);

            }
        }
        if(avlNode != NULL)
        {
             setHeight(avlNode); 
             avlNode = balanceAVL(avlNode);
        }
       
        noOfNodes--;
        return avlNode;
    }

    bool erase(T1 key)
    {
        if(root == NULL) return false;

        int Size = noOfNodes;

        root = actualErase(root, key);

        return noOfNodes < Size;
    }



    void inorder()
    {
        actualInorder(root);
        cout<<endl;
    }
    void actualInorder(Node* root)
    {
        if(root == NULL) return;
        actualInorder(root->left);
        // cout<<"{"<<root->key<<", "<<root->value<<"}"<<endl;
        cout<<root->value<<" ";
        actualInorder(root->right);
    }

    T2& find(Node* avlNode,T1 key)
    {
        if(avlNode->key == key) return avlNode->value;
        else if(key < avlNode->key) return find(avlNode->left, key);
        else return find(avlNode->right, key);

    }
    T2& operator[](T1 key)
    {
        // cout<<"entering"
        if(contains(key) == false)
        {
            // Node* avlNode = new Node(key, T2());
            insert(key, T2());
           // cout<<"inserted default value"<<endl;
        }

        T2& value = find(root, key);
        return value;

            // cout<< value;

    }

    void clear()
    {
        actualClear(root);
        root = NULL;
        noOfNodes = 0;
    }

    void actualClear(Node* avlNode)
    {
        if(avlNode == NULL) return;
        actualClear(avlNode->left);
        // cout<<"{"<<root->key<<", "<<root->value<<"}"<<endl;
        // cout<<root->value<<" ";
        // Node* temp = root;
        // delete root;

        actualClear(avlNode->right);
        delete avlNode;
    }

    vector<T1> keys()
    {
        vector<T1> storeKeys;
        actualKeys(root, storeKeys);
        return storeKeys;
    }
    void actualKeys(Node* avlNode, vector<T1>& storeKeys)
    {
        if(avlNode == NULL) return;
        actualKeys(avlNode->left, storeKeys);
        // cout<<"{"<<root->key<<", "<<root->value<<"}"<<endl;
        storeKeys.push_back(avlNode->key);
        actualKeys(avlNode->right, storeKeys);
    }

    pair<bool, T1> lower_bound(T1 key)
    {
        if (root == NULL)
        {
            return make_pair(false, T1());
        }
        else
        {
            return actualLower(root, key);
        }
    }

    pair<bool, T1> actualLower(Node* avlNode, T1 key)
    {
        if(avlNode == NULL) return make_pair(false, T1());

        if(avlNode->key ==  key)
        {
            return make_pair(true, avlNode->key);
        }

        if(key > avlNode->key) return actualLower(avlNode->right, key);

        //at this point key > current node so now new need to find max value in left subtree rooted at current node
       pair<bool, T1> r = actualLower(avlNode->left , key );
        if (r.first == true)  // If we found a key in the left subtree
        return r;

        return make_pair(true, avlNode->key);       
    }

    pair<bool, T1> upper_bound(T1 key)
    {
        if (root == NULL)
        {
            return make_pair(false, T1());
        }
        else
        {
            return actualUpper(root, key);
        }
    }

    pair<bool, T1> actualUpper(Node* avlNode, T1 key)
    {
        if(avlNode == NULL) return make_pair(false, T1());

        if(avlNode->key ==  key)
        {
            avlNode = avlNode->left;
            if(avlNode == NULL) return make_pair(false, T1());
            else return make_pair(true, avlNode->key);
        }

        if(key > avlNode->key) return actualUpper(avlNode->right, key);

        //at this point key > current node so now new need to find max value in left subtree rooted at current node
       pair<bool, T1> r = actualUpper(avlNode->left , key );
        if (r.first == true)  // If we found a key in the left subtree
        return r;

        return make_pair(true, avlNode->key);       
    }

    int pairCounts()
    {
        return pairCount(root);
    }

};



// int main()
// {
//     //cout<<"yo"<<endl;

//         orderedMap <int, int> map;
//         int key, val;
//         map.insert(15, 15);
//         cout<<"192"<<endl;
//         map.insert(8, 8);
//         cout<<"193"<<endl;
//         map.insert(10, 10);
//         cout<<"194"<<endl;
//         cout<<endl;
//         map.insert(2, 2);
//         cout<<"195"<<endl;
//         map.insert(11, 11);
//         cout<<"196"<<endl;
//         map.insert(9, 9);
//         cout<<"197"<<endl;
//         map.insert(12, 12);
//         cout<<"198"<<endl;
//         map.inorder();
//         // map.clear();
//         // map.inorder();
//         // cout << boolalpha << map.empty() << endl;
//         // cout<<map.size()<<endl;
//         // map.erase(11);
//         // map.inorder();
//         // map.erase(12);
//         // map.inorder();
//         // map.erase(10);
//         // map.inorder();

//         vector<int> keys = map.keys();
//         for(auto i:keys)
//         {
//             cout<<i<<" ";
//         }
//         cout<<endl;

//         pair<bool, int> res;
//         res = map.lower_bound(2);
//         if(res.first == false) cout<<"false"<<endl;
//         else
//         {
//             cout<<"true"<<endl;
//             cout<<res.second<<endl;
//         }

//         res = map.upper_bound(2);
//         if(res.first == false) cout<<"false"<<endl;
//         else
//         {
//             cout<<"true"<<endl;
//             cout<<res.second<<endl;
//         }
//         // // cout<<map[122]<<endl;
//         // cout<<map[2]<<endl;
//         // map.inorder();
//         // cout<<map.size()<<endl;
//         // map.erase(10);
//         // map.inorder();

//         // map.insert(1, 15);
//         // map.insert(1, 15);
// }

int main()
{
    orderedMap <int, int> map;
    int key;
    int val;
    pair<bool, int> res;
    vector<int> keys;
    int choice = -1;
    while (choice != 0) {
        cin >> choice;
        if (choice == 1) {
            cout << boolalpha << map.empty() << endl;
        }
        else if (choice == 2) {
            cout << map.size() << endl;
        }
        else if (choice == 3) {
            cin>>key;
            cout << boolalpha << map.contains(key) << endl;
        }
        else if (choice == 4) {
            cin>>key>>val;
            cout << boolalpha << map.insert(key, val) << endl;
            // map.inorder();
        }
        else if (choice == 11) {
            // cout << boolalpha << d.pop_back() << endl;
            map.inorder();
        }
        else if (choice == 5) {
            cin>>key;
            cout << boolalpha << map.erase(key) << endl;
        }
        else if (choice == 6) {
            cin>>key;
            cout << map[key] << endl;
        }
        else if (choice == 7) {
            map.clear();
        }
        else if (choice == 8) {
         keys = map.keys();
            for(auto i:keys)
            {
                cout<<i<<" ";
            }
            cout<<endl;
        }

        else if (choice == 9) {
            cin>>key;
            // pair<bool, int> res;
            res = map.lower_bound(key);
            if(res.first == false) 
            {
                cout<<"false"<<endl;
            }
            else
            {
                cout<<"true"<<endl;
                cout<<res.second<<endl;
            }
        }
        else if (choice == 10) {
            cin>>key;
            // pair<bool, int> res;
            res = map.upper_bound(key);
            if(res.first == false) 
            {
                cout<<"false"<<endl;
            }
            else
            {
                cout<<"true"<<endl;
                cout<<res.second<<endl;
            }
        }
        else if (choice == 0)
        {
            return 0;
        }
        else
            cout<<"Jaldi yaha se hato"<<endl;
    }
    return 0;
}