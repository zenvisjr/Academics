#include <iostream>
#include <ctime>
#include <vector>
// #include <queue>
using namespace std;

template<typename T>

class treap
{
    public:
    struct Node
    {
        T value;
        int priority;
        int size;
        Node* left;
        Node* right;

        //creating a new Node will take 2 values, item and val and will store them in key and value, initilise left and right to null and height to 1
        Node(T key)
        {
            value = key;
            priority = rand();
            size = 1;
            left = NULL;
            right = NULL;
        }
    };

    int noOfNodes;                       //no of nodes present in treap
    Node* root;                         // root node of treap
    // int index;                          // index of inserted node

    //constructor for the treap class
    treap()
    {
        
        noOfNodes = 0;
        root = NULL;
        // index = 0;
    }

    //helper functions

    // function to get size of a node
    int treeSize(Node* treapNode)
    {
        if(treapNode == NULL) return 0;
        else return treapNode->size;
    }
    
    // function to set size of each newly added node
    void setSize(Node* treapNode)
    {
        if(treapNode != NULL)
        {
            treapNode->size = 1 + treeSize(treapNode->left) + treeSize(treapNode->right);
        }
    }
    Node* rightRotation(Node* father)
    {
        Node* child = father->left;
        father->left = child->right;    //this is to handle subtree rooted at child's right node
        child->right = father;

        // setSize(father);
        setSize(child->left);
        setSize(child->right);
        setSize(child);

        return child;
    }

    Node* leftRotation(Node* father)
    {
        Node* child = father->right;
        father->right = child->left;   //this is to handle subtree rooted at child's left node
        child->left = father;

        // setSize(father);
        setSize(child->left);
        setSize(child->right);
        setSize(child);

        return child;
    }

    // bool search(Node* treapNode, int key)
    // {
    //     if(treapNode == NULL) return false;
    //     else if (key < treapNode->value)
    //     {
    //         search(treapNode->left, key);
    //     }
    //     else if (key > treapNode->value)
    //     {
    //         search(treapNode->right, key);
    //     }
    //     else
    //     {
    //         return true;
    //     }
    // }

    //main function implementaion 

    bool empty()
    {
        if(noOfNodes > 0) return false;
        else return true;
    }

    int size()
    {
        if(root != NULL)
        return root->size;
        else return 0;
    }

    void clear()
    {
        
        actualClear(root);
        root = NULL;
        noOfNodes = 0;
    }

    void actualClear(Node* treapNode)
    {
        if(treapNode == NULL) return;
        actualClear(treapNode->left);
        actualClear(treapNode->right);
        delete treapNode;
    }

    int insert(T val)
    {
        // //used to store index where value is inserted
        int index = 0;
        root = actualInsert(root, val, index);
        //if we successfuuly return then node must be inserted
        noOfNodes++;
        //return the index of node inserted
        return index;
    }

    Node* actualInsert(Node* treapNode, T val, int &index, int heplMe=0)
    {
        if(treapNode == NULL)
        {
            Node* newNode = new Node(val);
            // temp->size = 1; 
            index = heplMe;
            return newNode;
        }
        if(val <= treapNode->value) 
        {
            treapNode->left = actualInsert(treapNode->left, val, index, heplMe); // no adjustment for left subtree
            
            if (treapNode->left && treapNode->left->priority > treapNode->priority) 
            {
                treapNode = rightRotation(treapNode);
            }
        }
        else
        {
            int leftSize = findLeftTreapSize(treapNode);
            treapNode->right = actualInsert(treapNode->right, val, index, heplMe + leftSize + 1); // adjust for right subtree
            if (treapNode->right && treapNode->right->priority > treapNode->priority) 
            {
                treapNode = leftRotation(treapNode);
            }
        } 
        setSize(treapNode);
        return treapNode;
    }


    bool erase(int index)
    {
        //checking if the given index is out of bounds, if yes then return false
        if(index < 0 || index > noOfNodes) return false;

        //calling the helper function actualErase and starting from the root to remove the node at the index
        root = actualErase(root, index);
        //once node is deleted successfully, decrement the total no of nodes
        noOfNodes--;
        return true;
    }

    Node* actualErase(Node* treapNode, int index) 
    {
        //checking if current node is null
        if (treapNode == NULL) 
        {
            return NULL;
        }
        //initializing leftSize to zero and then update it to the size of the left subtree if it exists
        int leftSize = findLeftTreapSize(treapNode);
        
        //if the index is smaller than the size of the left subtree, then the node to be removed must be in the left subtree. 
        //the function then recursively calls itself for the left child
        if (index < leftSize) 
        {
            treapNode->left = actualErase(treapNode->left, index);
        } 
        
        else if (index > leftSize) 
        {
            index = index - (leftSize + 1);
            treapNode->right = actualErase(treapNode->right, index);
        } else 
        //If the index matches the size of the left subtree, then the current node is the one to be removed. 
        //The removeNode function is called to remove it.
        {
            treapNode = removeNode(treapNode);
        }
        //Finally, return the current node (treapNode), which may or may not have been modified.
        setSize(treapNode);
        return treapNode;
}

    Node* removeNode(Node* treapNode) 
    {
        // checks if the node to be removed is a leaf node
        if (treapNode->left == NULL && treapNode->right == NULL) 
        {
            delete treapNode;
            setSize(treapNode);
            return NULL;
        }
        //This block checks if the node has a left child and either no right child or a right child with lower priority. 
        //If so, it performs a right rotation to push the node to be removed down to the right
        if (treapNode->left != NULL && (treapNode->right == NULL || treapNode->left->priority > treapNode->right->priority)) 
        {
            treapNode = rightRotation(treapNode);
            treapNode->right = removeNode(treapNode->right);
        } 
        else 
        {
            treapNode = leftRotation(treapNode);
            treapNode->left = removeNode(treapNode->left);
        }
        setSize(treapNode);
        return treapNode;
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

    int indexOf(T val) 
    {
        int index = 0;
        return actualIndexOf(root, val, index);
    }

    int actualIndexOf(Node* treapNode, T val, int& index) 
    {
        //if node not found return -1
        if (treapNode == NULL) 
        {
            return -1; 
        }

        if (val < treapNode->value) 
        {
            return actualIndexOf(treapNode->left, val, index);
        } 
        else if (val > treapNode->value) 
        {
            // whrn going right, update the index to skip over the left subtree and the current node
            int leftSize = findLeftTreapSize(treapNode);
            index += 1 + leftSize;
            return actualIndexOf(treapNode->right, val, index);
        } 
        else 
        {
            // Value found, index is the sum of sizes of left subtrees encountered
            while(treapNode->left != NULL && treapNode->left->value == val)
            {
                treapNode = treapNode->left;
            }
            int leftSize = findLeftTreapSize(treapNode);
            index += leftSize;
            return index;
        }
    }

    T atIndex(int index) 
    {
        //if index is out of bound then return default value of T
        if (index < 0 || index >= noOfNodes) 
        {
            return T();  
        }
        return actualAtIndex(root, index);
    }

    T actualAtIndex(Node* treapNode, int index) 
    {
        // if current node is null then return default value of T
        if (treapNode == NULL) 
        {
            return T();  
        }

        int leftSize = findLeftTreapSize(treapNode);

        if (index < leftSize) 
        {
            return actualAtIndex(treapNode->left, index);
        } 
        else if (index > leftSize) 
        {
            
            index = index - leftSize - 1;
            return actualAtIndex(treapNode->right, index);
        } 
        else 
        {
            // Node found at index
            return treapNode->value;
        }
    }

    treap<T>* merge(treap<T> *t2) 
    {
        // Create a new treap to store the result of the merge
        treap<T>* mergedTreap = new treap<T>();
        mergedTreap->root = actualMerge(root, t2->root);
        mergedTreap->noOfNodes = noOfNodes + t2->noOfNodes;
        return mergedTreap;
    }

    Node* actualMerge(Node* root1, Node* root2) 
    {
        // if (root1 == NULL || root == NULL) 
        // {
        //     return root1 ? root1 : root2;
        // }

        if(root1 == NULL) return root2;
        if(root2 == NULL) return root1;

        // lets choose the root with higher priority as the new root
        if (root1->priority > root2->priority) 
        {
            // cout<<"415"<<endl;
            root1->right = actualMerge(root1->right, root2);
            setSize(root1);
            return root1;
        } 
        else 
        {
            // cout<<"422"<<endl;
            root2->left = actualMerge(root1, root2->left);
            setSize(root2);
            return root2;
        }
    }
    //Splits the treap at given index such that the elements before the given index are in the first treap and the elements from the index(and afterwards) are in the second treap
    pair<treap<T>*, treap<T>*> split(int index) //modifies original treap so after modification if we traverse inorder then we will only get left portion
    {
        //if index is out of bound then return default value of T
        if (index < 0 || index > noOfNodes) 
        {
            return {NULL, NULL};  
        }
        // Creating two new treaps pointers to point to the splited treaps]
        treap<T> *leftTreap = new treap<T>();
        treap<T> *rightTreap = new treap<T>();

        //create two new nodes to store the splited result
        Node* newLeft;
        Node* newRight;
    
        actualSplit(root, index, newLeft, newRight);

        //Assigning new nodes created to the new treap pointers
        leftTreap->root = newLeft;
        rightTreap->root = newRight;
        leftTreap->noOfNodes = index;
        rightTreap->noOfNodes = noOfNodes - index;
        
        return {leftTreap, rightTreap};
    }

    void actualSplit(Node* treapNode, int index, Node*& left, Node*& right) 
    {
        if (treapNode == NULL) 
        {
            // cout<<"Entering null condition"<<endl;
            left = right = NULL;
            return;
        }

        int leftSize = findLeftTreapSize(treapNode);

        if (index <= leftSize) 
        {
            // cout<<"Enering <= cond"<<endl;

            // Spliting happen in the left subtree
            actualSplit(treapNode->left, index, left, treapNode->left);
            right = treapNode;
        } 
        else 
        {
            // cout<<"Enering else cond"<<endl;

            // Spliting happen in the right subtree
            actualSplit(treapNode->right, index - leftSize - 1, treapNode->right, right);
            left = treapNode;
        }

        setSize(treapNode);
    }
    //Deletes the values between given indices (inclusive) and returns true if the whole index range was valid (completely inside the treap) else returns false
    bool erase(int first, int last) 
    {
        if (first < 0 || last >= noOfNodes || first > last) 
        {
            // cout << "Condition 1 failed" << endl;
            return false;
        }
        int currentNodes = noOfNodes;
        // cout<<currentNodes<<endl;
        auto firstSplit = split(first);
        
        // firstSplit.first->inorder();
        // firstSplit.second->inorder();

        //  delete firstSplit.first;

        // Update the root to point to the left split
        root = firstSplit.second->root;
        noOfNodes = root->size;
        // cout<<"No of nodes: "<<noOfNodes<<endl;

        // if(firstSplit.first == NULL || left_and_right.second == NULL) 
        // {
        // // cout << "Condition 2 failed" << endl;
        // return false;
        // }

        treap<T>* left = firstSplit.first;
        // treap<T>* right = firstSplit.second;

        int secondSplitIndex = last - first +1;
        // if(noOfNodes == 1) secondSplitIndex = last - first;
        // else secondSplitIndex = last - first +1;

        auto secondSplit = split(secondSplitIndex);
        // secondSplit.first->inorder();

        // firstSplit.first->inorder();
        // secondSplit.second->inorder();
        // if(secondSplit.first == NULL || secondSplit.second == NULL) {
        // cout << "Condition 3 failed" << endl;
        // return false;
        // }

        // treap<T>* middle = secondSplit.first;
        treap<T>* right = secondSplit.second;

        secondSplit.first->clear();
        delete secondSplit.first;

        treap<T>* mergedTreap = left->merge(right);

        root = mergedTreap->root;
        noOfNodes = currentNodes - (last-first+1); 

        // cout<<noOfNodes<<endl;

        // finally delete useless treaps made during the processs
        firstSplit.second->root = NULL;
        secondSplit.first->root = NULL;
        secondSplit.second->root = NULL;
    
        delete firstSplit.second;
        delete secondSplit.first;
        delete secondSplit.second;
        // Avoid deleting mergedTreap as it shares the root node with the original treap
        return true;
    }
    //Returns a pointer to the new treap consisting of values between given indices (inclusive) if the index range was valid else returns nullptr
    treap<T>* slice(int first, int last) 
    {
        if(first < 0 || last >= noOfNodes || first > last) 
        {
            return NULL;
        }

        auto firstSplit = split(first);

        firstSplit.first->root = NULL;
        delete firstSplit.first;

        root = firstSplit.second->root;
        noOfNodes = root->size;
        int secondSplitIndex = last - first + 1;

        auto secondSplit = split(secondSplitIndex);

        treap<T>* slicedTreap = new treap<T>();
        slicedTreap->root = secondSplit.first->root;
        slicedTreap->noOfNodes = last - first;

        // finally delete useless treaps made during the processs
        firstSplit.second->root = NULL;
        secondSplit.first->root = NULL;
        secondSplit.second->root = NULL;
    
        delete firstSplit.second;
        delete secondSplit.first;
        delete secondSplit.second;

        return slicedTreap;
    }

    // Returns the number of elements strictly less than `val`
    int lower_bound(T val) 
    {
        return actualLowerBound(root, val);
    }

    
    //doubt of failing
    int actualLowerBound(Node* treapNode, T val) 
    {
        if (treapNode == NULL) return 0;


        if (val <= treapNode->value) 
        {
            return actualLowerBound(treapNode->left, val);
        } 
        else 
        {
            //finding size of left tree
            int leftSize = findLeftTreapSize(treapNode);
            //as val is greater than nodes value we have to move right and add the no of nodes on its left
            return 1+leftSize + actualLowerBound(treapNode->right, val);
        }
    }

    //Returns the number of elements less than or equal to `val`
    int upper_bound(T val) 
    {
        return actualUpperBound(root, val);
    }

    int actualUpperBound(Node* treapNode, T val) 
    {
        if (treapNode == NULL) return 0;

        if (val < treapNode->value) 
        {
            return actualUpperBound(treapNode->left, val);
        } 
        else 
        {
            //finding size of left tree
            int leftSize = findLeftTreapSize(treapNode);

            //as val is greater than nodes value we have to move right and add the no of nodes on its left
            return leftSize + 1 + actualUpperBound(treapNode->right, val);
        }
    }
    int findLeftTreapSize(Node* treapNode)
    {
        if(treapNode->left != NULL)
        {
            return treapNode->left->size;
        }
        else return 0;
    }


    //Returns the number of elements equal to `val`
    int count(T val) 
    {
        return actualCount(root, val);
    }

    int actualCount(Node* treapNode, T val) 
    {   //if search ended at NULL, it means no one is equal to val, so return 0
        if (treapNode == NULL) return 0;

        if (val < treapNode->value) 
        {
            return actualCount(treapNode->left, val);
        } 
        else if (val > treapNode->value) 
        {
            return actualCount(treapNode->right, val);
        }
        else 
        { // we found a node whose value is equal to val
            return 1 + actualCount(treapNode->left, val) + actualCount(treapNode->right, val);
        }
    }

    //Returns the vector of values in the sorted order
    vector<T> to_array() 
    {
        //initilise a vector to store all values
        vector<T> val;
        printTreap(root, val);
        return val;
    }

    void printTreap(Node* treapNode, vector<T>& val) 
    {
        if (treapNode == NULL) return;

        printTreap(treapNode->left, val);
        val.push_back(treapNode->value);
        printTreap(treapNode->right, val);
    }











};

// int main() {
    // // First treap
    // treap<int> t1;
    // cout << "Size of t1: " << t1.size() << endl;
    // cout << "Is t1 empty? " << (t1.empty() ? "Yes" : "No") << endl;

    // t1.insert(50);
    // t1.insert(60);
    // t1.insert(70);
    // t1.insert(55);
    // t1.insert(45);
    // t1.insert(80);
    // t1.insert(75);
    // t1.inorder();
    // t1.erase(4);
    // t1.inorder();
    // t1.erase(4);
    // t1.inorder();
    // t1.erase(13);
    //     t1.insert(80);
    // t1.insert(75);
    //     t1.insert(80);
    // t1.insert(75);
    // t1.insert(75);
    // // t1.inorder();
    // // // t1.insert(45);
    // // t1.insert(81);
    // // t1.insert(1);
    // t1.inorder();

    // // cout << "Index of 45 in t1: " << t1.indexOf(45) << endl;
    // // cout << "Index of 60 in t1: " << t1.indexOf(60) << endl;
    // // cout << "Value at index 4 in t1: " << t1.atIndex(4) << endl;
    // // cout << "Value at index 8 in t1: " << t1.atIndex(8) << endl;

    // // // Second treap
    // // treap<int> t2;
    // // t2.insert(100);
    // // t2.insert(90);
    // // t2.insert(85);
    // // t2.insert(120);
    
    // // t2.inorder();

    // // // Merge treaps
    // // treap<int>* mergedTreap = t1.merge(&t2);

    // // mergedTreap->inorder();

    // // // Clean up
    // // delete mergedTreap;

    // //Split the treap at index 3
    // // pair<treap<int>*, treap<int>*> splittedTreaps = t1.split(4);
    // // if(splittedTreaps.first == NULL && splittedTreaps.second == NULL) cout<<"Invalid index"<<endl;
    // // else
    // // {
    // //         cout << "Left treap after split: ";
    // //     splittedTreaps.first->inorder();
    // //     cout << "Size of t1: " << splittedTreaps.first->size() << endl;
    
    // //     cout << "Right treap after split: ";
    // //     splittedTreaps.second->inorder();
    // //     cout << "Size of t1: " << splittedTreaps.second->size() << endl;
    // // }


    //     //Erase the range [2, 4] (inclusive) from the treap
    //     // bool eraseResult = t1.erase(2, 5);
    //     // // cout<<eraseResult<<endl;
    //     // cout << "Erase result: " << (eraseResult ? "true" : "false") << endl;

    //     // //Display the treap after the range erase
    //     // cout << "Treap after range erase: ";
    //     // t1.inorder();
    //     // cout << endl;

    //     // Previous code
    // cout << "Lower bound for value 40: " << t1.lower_bound(45) << endl;
    // cout << "Lower bound for value 50: " << t1.lower_bound(50) << endl;
    // cout << "Lower bound for value 55: " << t1.lower_bound(70) << endl;

    // cout << "Lower bound for value 40: " << t1.upper_bound(45) << endl;
    // cout << "Lower bound for value 50: " << t1.upper_bound(50) << endl;
    // cout << "Lower bound for value 55: " << t1.upper_bound(56) << endl;

    // // Previous code
    // cout << t1.count(50) << endl;
    // cout  << t1.count(75) << endl;
    // cout << t1.count(80) << endl;

    // t1.insert(100);
    // t1.insert(75);
    // t1.insert(75);
    // t1.insert(100);

    // cout << t1.count(100) << endl;
    // cout  << t1.count(75) << endl;
    // cout << t1.count(80) << endl;

    // // Previous code
    // vector<int> arr = t1.to_array();
    // for(int val : arr) {
    //     cout << val << " ";
    // }
    // cout << endl;


//     return 0;
// }

    

int main()
{
    treap <int> t;
    treap <int> t2;
    treap<int>* mergedTreap;
    treap<int>* slicedTreap;

    pair<treap<int>*, treap<int>*> splitedTreap;
    
    // treap <int> t2;
    int val;
    int idx, first, second, last;

    pair<bool, int> res;
    vector<int> keys;

    //     t.insert(50);
    // t.insert(60);
    // t.insert(70);
    // t.insert(55);
    // t.insert(45);
    // t.insert(80);
    // t.insert(75);
    // t.insert(100);
    // t.insert(45);
    // t.insert(80);
    // t.insert(75);
    // t.inorder();
    // t.levelOrderTraversal();


    

    int choice = -1;
    while (choice != 0) {
        cin >> choice;
        if (choice == 1) {
            cout << boolalpha << t.empty() << endl;
        }
        else if (choice == 2) {
            cout << t.size() << endl;
        }
        else if (choice == 3) {
             t.clear();
        }
        else if (choice == 4) {
            cin>>val;
            cout << t.insert(val) << endl;
            // t.inorder();
            // cout<<"level order: ";
            // t.levelOrderTraversal();
            // map.inorder();
        }
        else if (choice == 5) {
            cin>>idx;
            cout << boolalpha << t.erase(idx) << endl;
            // t.inorder();
            // t.levelOrderTraversal();
        }
        else if (choice == 6) {
            cin>>val;
            cout << t.indexOf(val) << endl;
        }
        else if (choice == 7) {
            cin>>idx;
            cout << t.atIndex(idx) << endl;
        }
        else if (choice == 8) {
            // treap<int>* t2;
            treap<int>* t2 = new treap<int>();
            // t2->insert(100);
            // t2->insert(200);
            // t2->insert(150);

            // int n;
            // cin >> n;
            // for (int i = 0; i < n; i++) 
            // {
            //     int val;
            //     cin >> val;
            //     t2->insert(val);
            // }

            // Now, merging t with t2
            mergedTreap = t.merge(t2);
            delete t2; 

            // mergedTreap->inorder(); 
            // cout << endl;

            // If you want the merged treap to replace t:
            // t.clear();
            // t.root = mergedTreap->root;
             t.noOfNodes = mergedTreap->noOfNodes;
             delete mergedTreap; 

        }

        else if (choice == 9) {
            cin >> idx;
            splitedTreap = t.split(idx);

            // if(splitedTreap.first == NULL && splitedTreap.second == NULL) cout<<"Invalid index"<<endl;
            // else
            // {
            //     cout << "Left treap after splitting: ";
            //     splitedTreap.first->inorder();
            //     cout << endl;

            //     cout << "Right treap after splitting: ";
            //     splitedTreap.second->inorder();
            //     cout << endl;
            // }

        }
        else if (choice == 10) {
            cin>>first;
            cin>>second;
            cout << boolalpha << t.erase(first, second) << endl;
            // t.inorder();
        }
        else if(choice == 11) {
            cin>>first;
            cin>>last;
            // cout<<"852"<<endl;
            slicedTreap = t.slice(first, last);
            // if(slicedTreap == NULL) cout<<"\0"<<endl;
            // // else
            // // {
            // //     cout << "Sliced treap: ";
            //     slicedTreap->inorder();
            //     cout << endl;
            // }
            

        }

        else if (choice == 13) {
            cin>>val;
            cout<<t.upper_bound(val)<<endl;
        }
        else if (choice == 12) {
            cin>>val;
            cout<<t.lower_bound(val)<<endl;
        }
        else if (choice == 14) {
            cin>>val;
            cout<<t.count(val)<<endl;
        }
        else if (choice == 15) {
            keys = t.to_array();
            for(auto node : keys) cout<<node<<" ";
            cout<<endl;
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



