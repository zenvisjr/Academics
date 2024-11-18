#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <numeric>
using namespace std;

struct Node
{
    bool check;
    Node* arr[256];


    Node()
    {
        for(int i=0; i<256; i++)
        {
            arr[i] = NULL;
        }

        check = false;
    }
};


void insert(Node* root, string s)
{
    //make temp node that point to root
    Node* temp = root;

    //find length of string s
    int n = s.length();

    for(int i=0; i<n; i++)
    {
       if(temp->arr[s[i]] == NULL)
       {
        //for each charater in string s, we are creating a new node
        temp->arr[s[i]] = new Node;
        temp->arr[s[i]]->check = false;
       }
       //move to next charater
       temp = temp->arr[s[i]];
    }
    //at end of string make check true
    temp->check = true;
}

bool spellCheck(Node* root, string key)
{
    Node* temp = root;

    int n = key.length();
    for(int i=0; i<n; i++)
    {
        if(temp->arr[key[i]] == NULL)
        {
            return false;
        }

          temp = temp->arr[key[i]];
    }
    if(temp->check == true)
    {
        return true;
    }
    return false;
    
}

void dfs(Node* node, string s, vector<string>& res)
{

    if(node == NULL)
    {
        return;
    }
    
    //cout<<"priting current string: "<<s<<endl;
    // for (const string& s : res)
    //     {
    //         cout << s << endl;
    //     }
    //cout<<"entering dfs"<<endl;
    if (node->check == true)
    {
        res.push_back(s);
    }

    for (unsigned char c = 0; c < 256; c++)
    {
            //cout << "In DFS main loop, c = " << static_cast<int>(c) << endl;  // Debug line
        // if(node == NULL)
        // return;
       // cout<<"entering dfs main loop"<<endl;
        if (node->arr[c] != NULL)
        {
           // cout<<"again calling dfs"<<endl;
            dfs(node->arr[c], s + static_cast<char>(c), res);
        }
        if(c == 255)
            break;
    }
}

vector<string> AutoComplete(Node* root, string key)
{
    vector<string> result;
    Node* temp = root;
    int n = key.length();

    for (int i = 0; i < n; i++)
    {
        if (temp->arr[key[i]] == NULL)
        {
            return result;
        }
        temp = temp->arr[key[i]];
    }
    //cout<<"just entering dfs"<<endl;
    dfs(temp, key, result);
    //cout<<"leaved dfs"<<endl;
    // for (const string& s : result)
    //     {
    //         cout << s << endl;
    //     }
    return result;
}


// void dfss(Node* node, const string& key, vector<int>& dp, string current, vector<string>& result) 
// {
//     //cout<<"entering dfss"<<endl;
//     if(node->check) {
//         //cout<<"entering node check dfss"<<endl;
//         if(dp.back() <= 3) {
//             result.push_back(current);
//         }
//         //cout<<"leaving node check dfss"<<endl;
//     }

//     for(unsigned char i = 0; i < 256; i++) 
//     {
//         //cout<<"entering loop dfss"<<endl;
//         Node* child = node->arr[i];
//         if(child != nullptr) {
//             char c = static_cast<char>(i);  // Use ASCII value directly

//             vector<int> new_dp(1, dp[0] + 1);
//             for(int j = 1; j < dp.size(); ++j) {
//                 int cost = (key[j - 1] == c) ? 0 : 1;
//                 new_dp.push_back(min({dp[j] + 1, new_dp.back() + 1, dp[j - 1] + cost}));
//             }

//             if(*min_element(new_dp.begin(), new_dp.end()) <= 3) {
//                 dfss(child, key, new_dp, current + c, result);
//             }
//         }

//         if(i == 255)
//             break;
//     }
// }

// dfss function performs a dfs on our trie and is used for finding all the words within a certain edit distance (<=3) from a given key
void dfss(Node* node, const string& key, vector<int>& dp, string current, vector<string>& result) 
{
    //entering dfss
    // Check if the current node marks the end of a valid word in the trie
    if(node->check) 
    {
        //entering node check dfss
        // If the edit distance is less than or equal to 3, add the current string to the result
        if(dp.back() <= 3) {
            result.push_back(current);
        }
        //leaving node check dfss
    }

    // Loop through all possible children nodes (256 ASCII characters)
    for(unsigned char i=0; i<256; i++) 
    {
        //entering loop dfss
        // Get the child node for the current character
        Node* child = node->arr[i];
        
        // If the child node exists, proceed further
        if(child != NULL) 
        {
            // Convert the unsigned char to its ASCII character
            char c = static_cast<char>(i);  

            // Initialize a new edit distance array with the first value
            vector<int> new_dp(1, dp[0]+1);
            
            // Compute the new edit distances for the current string
            int n = dp.size();
            for(int j=1; j<n j++) 
            {
                // Calculate the cost of edit (substitution). 0 if no change, 1 otherwise.
                int cost = (key[j-1] == c) ? 0 : 1;
                
                // Update the new_dp array with the minimum edit distance at this point.
                new_dp.push_back(min({dp[j] + 1, new_dp.back() + 1, dp[j - 1] + cost}));
            }

            // If the minimum edit distance so far is within the limit (<=3), proceed here
            if(*min_element(new_dp.begin(), new_dp.end()) <= 3) 
            {
                // Recursively call the dfss function for the child node
                dfss(child, key, new_dp, current + c, result);
            }
        }

        // Break the loop after the last ASCII character (255)
        if(i == 255)
            break;
    }
}


vector<string> autoCorrect(Node* root, string& key) 
{
    vector<string> result;
    vector<int> dp(key.size() + 1);
    iota(dp.begin(), dp.end(), 0);  // Initialize dp to [0, 1, 2, ..., key.size()]

    dfss(root, key, dp, "", result);

    return result;
}


// int main()
// {
//     vector<string> str = {"geekrs", "gee", "geeks", "ape", "apple", "geeksforgeeks", "geeksto"};
//     string key = "geek";
//     Node* root = new Node();

//     for (int i = 0; i < str.size(); i++)
//     {
//         insert(root, str[i]);
//     }

//     //Print true if the key exists
//     cout << spellCheck(root, key)<<endl;
//     //cout<<"hii"<<endl;

//     vector<string> v;
//     v = AutoComplete(root, key);
//     if(v.size()>0)
//     {
//         // cout << "no of words: " << v.size() << endl;
//         cout << v.size() << endl;
//         //sort(v.begin(), v.end());
//         for (const string& s : v)
//         {
//             cout << s << endl;
//         }
//     }
//     // else
//     // {
//     //     cout << "No words found with the given prefix." << endl;
//     // }

//     vector<string> complete = autoCorrect(root, key);

//     // cout << "no of words: " << complete.size() << endl;
//      cout << complete.size() << endl;
//     //std::sort(v.begin(), v.end());
    
//     for(const string& s : complete) 
//     {
//         cout << s << endl;
//     }
//     return 0;
// }

int main()
{
    int n, q;
    cin >> n >> q;
    vector<string> str(n);
    Node* root = new Node();
    
    // Reading the dictionary words
    for (int i = 0; i < n; i++)
    {
        cin >> str[i];
        insert(root, str[i]);
    }
    
    // Processing the queries
    for (int i = 0; i < q; i++)
    {
        int ai;
        string ti;
        cin >> ai >> ti;
        
        if (ai == 1) // Spell Check
        {
            cout << spellCheck(root, ti) << endl;
        }
        else if (ai == 2) // Autocomplete
        {
            vector<string> complete = AutoComplete(root, ti);
            cout << complete.size() << endl;
            for (auto s : complete)
            {
                cout << s << endl;
            }
        }
        else if (ai == 3) // Autocorrect
        {
            vector<string> correct = autoCorrect(root, ti);
            cout << correct.size() << endl;
            for (auto s : correct)
            {
                cout << s << endl;
            }
        }
    }

    return 0;
}


