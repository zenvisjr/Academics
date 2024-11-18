#include <iostream>
#include <vector>
#include <functional>
#include<limits>
// #include <pair>
using namespace std;
int maxNodeSize = 7;

class Rope
{
    public:
    struct Node
    {
        int weight;    //to store length of the string segment in the left subtree
        string* data;  // it is a pointer to the actual string segment, only valid for leaf nodes, for others it is NULL
        int height;    //used for balancing
        Node* left;
        Node* right;
        Node* parent;

        //constructor for leaf node    (it will called if length of string is <=20)
        Node(string str)
        {
            weight = str.size();
            data = new string(str);
            height = 1;
            left = NULL;
            right = NULL;
            parent = NULL;
        }

        //constructor for internal node   
        Node(Node* leftNode, Node* rightNode)
        {
            // if(left)
            // weight = leftNode->weight;             //doubt
            data = NULL;
            height = 1 + max(getHeight(leftNode), getHeight(rightNode));
            left = leftNode;
            right = rightNode;
            parent = NULL;
            if(leftNode != NULL) leftNode->parent = this;
            if(leftNode != NULL) rightNode->parent = this;
        }
    };

    int noOfNodes;                       //no of nodes present in rope
    Node* root;                         // root node of rope
    int totalStringSize;

    Rope()
    {
        
        noOfNodes = 0;
        root = NULL;
        totalStringSize = 0;
    }

    //function to get height of a node
    static int getHeight(Node* ropeNode)
    {
        if(ropeNode == NULL) return 0;
        else return ropeNode->height;
    }

    // function to set height of each newly added node
    void setHeight(Node* ropeNode)
    {
        if(ropeNode != NULL)
        {
            ropeNode->height = 1 + max(getHeight(ropeNode->left), getHeight(ropeNode->right));
        }
    }

    // function for all rotations LL, RR, RL, LR
    // Node* LL(Node* father)
    // {
    //     Node* child = father->left;
    //     father->left = child->right; 

    //     // Adjusting parent pointers
    //     if (child->right != NULL) 
    //     {
    //         child->right->parent = father;
    //     }
    //     child->parent = father->parent;
    //     father->parent = child;

    //     child->right = father;

    //     // Adjust weight for father and child
    //     father->weight = calculateWeght(father);
    //     child->weight = calculateWeght(child);

        
    //     // Ensure data pointers are null for internal nodes
    //     if (father->left != NULL || father->right != NULL) father->data = NULL;
    //     if (child->left != NULL || child->right != NULL) child->data = NULL;

    //     setHeight(father);
    //     setHeight(child);

    //     return child;
    // }

Node* LL(Node* father) 
{
    Node* child = father->left;
    father->left = child->right; 

    // Adjusting parent pointers
    if (child->right != NULL) 
    {
        child->right->parent = father;
    }
    // Check if father was the root
    if (father->parent == NULL) 
    {
        root = child;  // Update the root of the Rope if necessary
    } 
    else 
    {
        // Update the parent's child pointer
        if (father->parent->left == father) 
        {
            father->parent->left = child;
        } 
        else 
        {
            father->parent->right = child;
        }
    }
    child->parent = father->parent;
    father->parent = child;

    child->right = father;

    // Adjust weight for father and child
    father->weight = calculateWeght(father);
    child->weight = calculateWeght(child);

    // Ensure data pointers are null for internal nodes
    if (father->left != NULL || father->right != NULL) father->data = NULL;
    if (child->left != NULL || child->right != NULL) child->data = NULL;

    setHeight(father);
    setHeight(child);

    return child;
}


    // Node* RR(Node* father)
    // {
    //     Node* child = father->right;
    //     father->right = child->left; 

    //     // Adjusting parent pointers
    //     if (child->left != NULL) 
    //     {
    //         child->left->parent = father;
    //     }
    //     child->parent = father->parent;
    //     father->parent = child;

    //     child->left = father;

    //     father->weight = calculateWeght(father);
    //     child->weight = calculateWeght(child);

    //         // Ensure data pointers are null for internal nodes
    //     if (father->left != NULL || father->right != NULL) father->data = NULL;
    //     if (child->left != NULL || child->right != NULL) child->data = NULL;

    //     setHeight(father);
    //     setHeight(child);

    //     return child;
    // }

Node* RR(Node* father) 
{
    Node* child = father->right;
    father->right = child->left; 

    // Adjusting parent pointers
    if (child->left != NULL) 
    {
        child->left->parent = father;
    }
    // Check if father was the root
    if (father->parent == NULL) 
    {
        root = child;  
    } 
    else 
    {
        // Update the parent's child pointer
        if (father->parent->left == father) 
        {
            father->parent->left = child;
        } 
        else 
        {
            father->parent->right = child;
        }
    }
    child->parent = father->parent;
    father->parent = child;

    child->left = father;

    // Adjust weight for father and child
    father->weight = calculateWeght(father);
    child->weight = calculateWeght(child);

    // Ensure data pointers are null for internal nodes
    if (father->left != NULL || father->right != NULL) father->data = NULL;
    if (child->left != NULL || child->right != NULL) child->data = NULL;

    setHeight(father);
    setHeight(child);

    return child;
}


    Node* RL(Node* father)
    {
        Node* child = father->right;
        father->right = LL(child); 

        // father->weight = calculateWeght(father);
        return RR(father);
    }

    Node* LR(Node* father)
    {
        Node* child = father->left;
        father->left = RR(child); 

        // father->weight = calculateWeght(father);
        return LL(father);
    }

        //function to find balance factor
    int balFactor(Node* ropeNode)
    {
        if(ropeNode == NULL) return 0;
        int bf = getHeight(ropeNode->left) - getHeight(ropeNode->right);
        return bf;
    }


    //function to balance rope tree
    Node* balanceRope(Node* ropeNode)
    {
        if(ropeNode == NULL) return NULL;
        int bf = balFactor(ropeNode);
        if(bf>1)
        {
            if(balFactor(ropeNode->left) > 0) ropeNode = LL(ropeNode);
            else ropeNode = LR(ropeNode);
            
        }
        else if(bf<-1)
        {
            if(balFactor(ropeNode->right) > 0) ropeNode = RL(ropeNode);
            
            else 
            {
                ropeNode = RR(ropeNode);
            }
        }

        // Continue balancing up the tree towards the root
        if(ropeNode->parent != NULL)
        {
            balanceRope(ropeNode->parent);
        }
        return ropeNode;
    }


    void rope(string s)
    {
        totalStringSize = s.size();
        if(root == NULL)
        {
            root = createNode(s);
        }
        else
        {
            root = nullptr;
            root = createNode(s);
        }
        
    }

    Node* createNode(string& s)
    {
        int stringSize = s.size();
        // cout<<stringSize<<endl;
        if(stringSize <= maxNodeSize)
        {
            Node* leafNode = new Node(s);
            noOfNodes++;
            return leafNode;
        }

        //finding middle point of string to divide it in half
        int mid = stringSize/2;
        
        // Creating two substrings out of it
        string leftStr = s.substr(0, mid);
        string rightStr = s.substr(mid);
        // cout<<leftStr<<endl;
        // cout<<rightStr<<endl;

        // Recursively creating nodes for each half.
        Node* leftNode = createNode(leftStr);
        Node* rightNode = createNode(rightStr);

        // let's create an internal node for left and right leaf node
        Node* internalNode = new Node(leftNode, rightNode);
        noOfNodes++;

        //finding weight of internal node
        // internalNode->weight = leftNode->weight;
        internalNode->weight = calculateWeght(internalNode);


        setHeight(internalNode);
        internalNode = balanceRope(internalNode);
        
        return internalNode;
    }
    int calculateWeght(Node *ropeNode)
    {
        if(ropeNode == NULL || ropeNode->left == NULL) return 0;
        Node* left = ropeNode->left;
        int leftWeight = 0;
        findWeight(left, leftWeight);
        return leftWeight;

    }

    void findWeight(Node* ropeNode, int& leftWeight)
    {
        if(ropeNode == NULL)
        {
            return;
        }
        else
        {
            leftWeight += ropeNode->weight;
            findWeight(ropeNode->right, leftWeight);
        }
        // if(ropeNode->left == NULL && ropeNode->right == NULL)
        // {
        //     leftWeight += ropeNode->weight;
        // }
        // findWeight(ropeNode->left, leftWeight);
        // findWeight(ropeNode->right, leftWeight);
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
        if (root->left==NULL && root->right==NULL)
        {
            cout<<*(root->data)<<"  ";
        }
        else
        {
            cout<<root->weight<<"  ";
        }
        
        actualInorder(root->right);
    }

    string to_string()
    {
        string myString;
        actualToString(root, myString);
        // cout<<myString<<endl;
        return myString;
        // cout<<endl;
    }
    void actualToString(Node* root, string &myString)
    {
        if(root == NULL) return;

        actualToString(root->left, myString);
        if (root->left==NULL && root->right==NULL)
        {
            // cout<<*(root->data);
            myString += *(root->data);
            
        }
        
        actualToString(root->right, myString);
    }

        void preorder()
    {
        actualPreorder(root);
        cout<<endl;
    }
    void actualPreorder(Node* root)
    {
        if(root == NULL) return;

        if (root->left==NULL && root->right==NULL)
        {
            cout<<*(root->data)<<"  ";
        }
        else
        {
            cout<<root->weight<<"  ";
        }

        actualPreorder(root->left);
        actualPreorder(root->right);
    }

//     void printstring(Rope *r)
// {
//     if (r==NULL)
//         return;
//     if (r->left==NULL && r->right==NULL)
//         cout << r->str;
//     printstring(r->left);
//     printstring(r->right);
// }
    bool empty()
    {
        if(root == NULL || noOfNodes == 0) return true;
        else return false;
    }

    int size()
    {
        return noOfNodes;
    }

    void clear()
    {
        actualClear(root);
        noOfNodes = 0;
        root = NULL;
    }
    void actualClear(Node* ropeNode)
    {
        if(ropeNode == NULL) return;
        actualClear(ropeNode->left);
        actualClear(ropeNode->right);
        delete ropeNode;
    }

    bool insert(int i, string s)
    {
        //checking if index is out of bounds according to current string stored in rope
        if(i<0 || i> totalStringSize) return false;

        //finding leaf node where insertion will be performed
        pair<Node*, int> data = findLeafNode(root, i);
        Node* insertionNode = data.first;
        i = data.second;
        // cout<<"updated index: "<<i<<endl;

        //extracting string stored in that node
        // if(insertionNode != NULL && insertionNode->data != NULL)
        // {
            string strToSplit = *(insertionNode->data);
            // cout<<strToSplit<<endl;
        // }
        //spliting the string on given index
        string splitPrefix = strToSplit.substr(0, i);
        string splitSuffix = strToSplit.substr(i);
        // cout<<splitPrefix<<endl;
        // cout<<splitSuffix<<endl;

        //concatenating the string to insert with prefix
        string strToInsert = splitPrefix + s;
        // cout<<strToInsert<<endl;

        //creating node for strToInsert 
        insertionNode->left = createNode(strToInsert);
        // actualInorder(insertionNode->left);
        insertionNode->right = createNode(splitSuffix);
        // cout<<"yoo"<<endl;
        insertionNode->data = NULL;
        insertionNode->weight = strToInsert.size();
        totalStringSize += s.size();
        
        //creating new node with given string and inserting it into the tree
        setHeight(insertionNode);
        insertionNode = balanceRope(insertionNode);
        reweight(insertionNode->parent);
        return true;
    }

    void reweight(Node* ropeNode)
    {
        while(ropeNode != NULL)
        {
            ropeNode->weight = calculateWeght(ropeNode);
            ropeNode = ropeNode->parent;
            
        }
    }
    pair<Node*, int> findLeafNode(Node* ropeNode, int i)
    {
        if(ropeNode ==NULL) return {NULL, i};

        //if current node is a leaf node return it
        if(ropeNode->left == NULL && ropeNode->right == NULL)
        {
            return make_pair(ropeNode, i);
        }

        // int weightOfNode = ropeNode->left->weight;
        //if weight of the left child is greater than index move to left
        if(ropeNode->left != NULL && ropeNode->weight > i)
        {
            // cout<<"left"<<endl;
            return findLeafNode(ropeNode->left, i);
        }
        //if weight of the left child is less than or equal to index move to right
        else if(ropeNode->right != NULL && ropeNode->weight <= i)
        {
            // cout<<"right"<<endl;
            int newIndex = i - ropeNode->weight;
            // cout<<newIndex<<endl;
            return findLeafNode(ropeNode->right, newIndex);
        }
        return {NULL, i};

    }

    char charAt(int index)
    {
        if(index < 0 || index >= totalStringSize) return '\0';
        else return actualCharAt(root, index);
    }

    char actualCharAt(Node* ropeNode, int index)
    {
        if(ropeNode == NULL) return '\0';

        //if current node is a leaf node return it
        if(ropeNode->left == NULL && ropeNode->right == NULL)
        {
            // cout<<"printing"<<endl;
            // cout<<index<<endl;
            return (*ropeNode->data)[index];
        }

        // int weightOfNode = ropeNode->left->weight;
        //if weight of the left child is greater than index move to left
        if(ropeNode->left != NULL && ropeNode->weight > index)
        {
            // cout<<"left"<<endl;
            return actualCharAt(ropeNode->left, index);
        }
        //if weight of the left child is less than or equal to index move to right
        else if(ropeNode->right != NULL && ropeNode->weight <= index)
        {
            // cout<<"right"<<endl;
            int newIndex = index - ropeNode->weight;
            // cout<<newIndex<<endl;
            return actualCharAt(ropeNode->right, newIndex);
        }
        return '\0';
    }

    Rope* concat(Rope* r2)
    {

        // concateNode->root = r->root;
        // Create a new rope with concatNode as its root
        Rope* concatenatedRope = new Rope();
        concatenatedRope->root = actualConcat(this->root, r2->root);
        
        if (concatenatedRope->root == this->root) 
        {
            concatenatedRope->totalStringSize = this->totalStringSize;
            concatenatedRope->noOfNodes = this->noOfNodes;
        } 
        else if (concatenatedRope->root == r2->root) 
        {
            concatenatedRope->totalStringSize = r2->totalStringSize;
            concatenatedRope->noOfNodes = r2->noOfNodes;
        } 
        else 
        {

            concatenatedRope->totalStringSize = this->totalStringSize + r2->totalStringSize;
            concatenatedRope->noOfNodes = 1 + this->noOfNodes + r2->noOfNodes; // 1 oot node is added
        }
    
        return concatenatedRope;
    }

    Node* actualConcat(Node* root1, Node* root2)
    {
        if(root1 == NULL) return root2;
        if(root2 == NULL) return root1;

        Node* concateNode = new Node(root1, root2);
        concateNode->weight = calculateWeght(concateNode);
        setHeight(concateNode);
        concateNode = balanceRope(concateNode);
        return concateNode;
    }

Rope* push_back(string& s) 
{

    Rope* newRope = new Rope();
    newRope->root = createNode(s); 
    newRope->totalStringSize = s.size();

    Rope* concatenatedRope = concat(newRope);
    // we assume that concat and createNode take care of balancing the Rope.

    return concatenatedRope;
}


    
};



// int main()
// {
//     Rope r;
//     cout<<boolalpha<<r.empty()<<endl;
//     cout<<r.size()<<endl;
//     // string str = "hy, my name is ayush.";
//     string str = "hy, my name";
//     // string str = " nahello naruto";
//     string str1 = "hello naruto";
//     r.rope(str);
// //     // cout<<"Index:"<<endl;
// //     // cout<<r.charAt(23)<<endl;
// //     // cout<<r.charAt(24)<<endl;
// //     // cout<<r.charAt(25)<<endl;
// //     // cout<<r.charAt(22)<<endl;
//     r.inorder();
//     r.preorder();
// //     // r.inorderStr();
//     cout<<r.to_string()<<endl;
//     cout<<boolalpha<<r.empty()<<endl;
//     cout<<r.size()<<endl;

    
//     // cout<<boolalpha<<r.insert(9, str1)<<endl;
//     // cout<<r.size()<<endl;
//     // r.inorder();
//     // r.preorder();
    
//     // cout<<boolalpha<<r.empty()<<endl;
//     // cout<<r.size()<<endl;
//     //     cout<<r.to_string()<<endl;


// //     // cout<<r.charAt(5)<<endl;
// //     // cout<<r.charAt(10)<<endl;
// //     // cout<<r.charAt(15)<<endl;
// //     // cout<<r.charAt(500)<<endl;
// //     // cout<<r.to_string()<<endl;


//     // testing concatenation
//     // Rope* r2 = new Rope();
//     // string str3 = "  is ayush rai. My nick name is zenvis.";
//     // r2->rope(str3);
//     // r2->noOfNodes;
//     // cout<<r2->to_string()<<endl;
//     // Rope* concatenatedRope = r.concat(r2);
//     // cout<<"Concatnation: "<<endl;
//     // cout<<concatenatedRope->to_string()<<endl;
//     //     cout<<boolalpha<<r.empty()<<endl;

//     // //makeing concatenated rope as default rope
//     //     r.root = concatenatedRope->root;
//     //     r.noOfNodes = concatenatedRope->noOfNodes;
//     //     r.totalStringSize = concatenatedRope->totalStringSize;

//     // cout<<r.size()<<endl;
//     // r.inorder();
//     // r.preorder();

// //     //again inserting after concate
// //         cout<<boolalpha<<r.insert(9, str1)<<endl;
// //     cout<<r.size()<<endl;
// //     r.inorder();
// //     r.preorder();
    
// //     cout<<boolalpha<<r.empty()<<endl;
// //     cout<<r.size()<<endl;
// //     cout<<r.to_string()<<endl;

//     //checking split 
//     // auto splitedRope = r.split(25);
//     // // Get the two ropes after the split
//     // Rope* leftRope = splitedRope.first;
//     // Rope* rightRope = splitedRope.second;

//     // // Check the content of the left and right ropes
//     // cout << "Left Rope: ";
//     // if (leftRope) {
//     //     cout<<leftRope->to_string()<<endl; 
//     //     leftRope->inorder();

//     // } else {
//     //     cout << "null";
//     // }
//     // cout << endl;

//     // cout << "Right Rope: ";
//     // if (rightRope) {
//     //     cout<<rightRope->to_string()<<endl; 
//     //     rightRope->inorder();
//     // } else {
//     //     cout << "null";
//     // }
//     // cout << endl;

//     //checking push_back
//     string s5 = " I love to play football!!";
//     Rope* newRope = r.push_back(s5);
//     cout<<"Push back: "<<endl;
//     //makeing concatenated rope as default rope
//     r.root = newRope->root;
//     r.noOfNodes = newRope->noOfNodes;
//     r.totalStringSize = newRope->totalStringSize;
//     cout<<r.to_string()<<endl;
//     cout<<boolalpha<<r.empty()<<endl;
//     r.inorder();
//     r.preorder();

//     //subrope
//     // Rope* slicedRope = r.subrope(5, 10);
//     // cout<<slicedRope->to_string()<<endl;




// //     cout<<r.size()<<endl;
// //     r.inorder();
// //     return 0;
// }

int main()
{
    Rope r;
    Rope* mergedRope;
    pair<Rope*, Rope*> splitedRope;
    string s;
    int index;
    int first, second, last;

    int choice = -1;
    while (choice != 0) {
        cin >> choice;
        if (choice == 1) {
            // cin>>s;
            cin.ignore(numeric_limits<streamsize>::max(), '\n'); // Clear the input buffer
            getline(cin, s);
            r.rope(s);
        }
        else if (choice == 2) {
            cout << boolalpha << r.empty() << endl;
        }
        else if (choice == 3) {
            cout << r.size() << endl;
        }
        else if (choice == 4) {
             r.clear();
        }
        else if (choice == 5) {
            cin>>index;
            // cin>>s;
            cin.ignore(numeric_limits<streamsize>::max(), '\n'); // Clear the input buffer
            getline(cin, s);
            cout <<boolalpha<< r.insert(index, s) << endl;
        }
        else if (choice == 7) {
            cin>>index;
            cout << r.charAt(index) << endl;
        }
        else if (choice == 9) {
            Rope* r2 = new Rope();
            string s2;
            // cin>>s2;
            cin.ignore(numeric_limits<streamsize>::max(), '\n'); // Clear the input buffer
            getline(cin, s2);
            r2->rope(s2);
            Rope* concatenatedRope = r.concat(r2);

            //makeing concatenated rope as default rope
            r.root = concatenatedRope->root;
            r.noOfNodes = concatenatedRope->noOfNodes;
            r.totalStringSize = concatenatedRope->totalStringSize;

        }
        else if (choice == 10) {
            // string s;
            cin.ignore(numeric_limits<streamsize>::max(), '\n'); // Clear the input buffer
            getline(cin, s);
            Rope* newRope = r.push_back(s);
            //making concatenated rope as default rope
            r.root = newRope->root;
            r.noOfNodes = newRope->noOfNodes;
            r.totalStringSize = newRope->totalStringSize;
        }
        else if (choice == 11) {
            cout<<r.to_string()<<endl;
            // r.inorder();
            // cout<<r.totalStringSize<<endl;
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