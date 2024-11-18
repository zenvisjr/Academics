#include <iostream>
#include <iomanip> 
using namespace std;

template <typename T>
class SparseOperation
{
    public:

    // int size;
    // int cap = 100;

    struct Sparse 
    {
        int row;
        int col;
        T data;
    };

    struct node
    {
        int row;
        int col;
        T data;
        node *next;
    };

    T** createMatrix(int row, int col)
    {
        T** matrix = new T* [row];
        for(int i=0; i<row;i++)
        {
            matrix[i] = new T [col];
        }

        return matrix;
    }


    // void length(int** matrix, int row, int col)
    // {
    //     ::size = 0;
    //     for(int i=0; i<row; i++)
    //     {
    //         for(int j=0; j<col; j++)
    //         {
    //             if(matrix[i][j] != 0)
    //             ::size++;
    //         }
    //     }
    //     //return size;
    // }


    void deleteMatrix(T** matrix, int row)
    {
        for(int i=0; i<row;i++)
        {
            delete[] matrix[i];
        }
        delete[] matrix;
    }


    void printMatrix(T** matrix, int row, int col)
    {
        for(int i=0; i<row; i++)
        {
            for(int j=0; j<col; j++)
            {
                cout<<matrix[i][j]<<" ";
            }
            cout<<endl;
            
        }
        
    }

    // void Array(int** matrix, int row, int col, int** arr)
    // {
    //     length(matrix, row, col);
    //     int k=0;
    //     for(int i=0; i<row; i++)
    //     {
    //         for(int j=0; j<col; j++)
    //         {
    //             if(matrix[i][j] != 0)
    //             {
    //                 arr[0][k] = i;
    //                 arr[1][k] = j;
    //                 arr[2][k] = matrix[i][j];

    //                 k++;
    //             }
    //         }
    //     }
    //     int cols = ::size;
    //     //printMatrix(arr, 3, cols);
    // }



    void create_node(node** head, int row, int col, T data)
    {
        node* temp = new node;

        temp->data = data;
        temp->row = row;
        temp->col = col;
        temp->next = NULL;
        //if head is empty
        if(*head == NULL)
        {
            
            *head = temp;
        }
        else
        {
            node* ptr = *head;
            while(ptr->next != NULL)
            {
                ptr = ptr->next;
            }
            ptr->next = temp; 
        }

        //return head;

    }
    // node* Linklist(int** matrix, int row, int col, node* head)
    // {
    //     cout<<"121"<<endl;

    //     //size = length(matrix);
    //     int k=0;
    //     for(int i=0; i<row; i++)
    //     {
    //         for(int j=0; j<col; j++)
    //         {
    //             if(matrix[i][j] != 0)
    //             {
    //                 create_node(&head, i, j, matrix[i][j]);
    //             }
    //         }
    //     }
    //     return head;

    // }

    void printList(node *start)
    {
        node *ptr = start;
        //cout << "row_position:";
        while (ptr != NULL)
        {
            cout << ptr->row << " "<<ptr->col << " "<< ptr->data <<endl;
            ptr = ptr->next;
        }
    }

    void initiliseMatrix(T **matrix, int row, int col)
    {
        //cout<<"172"<<endl;
        //cout<<row<<endl;
        //cout<<col<<endl;
        for(int i=0; i<row; i++)
        {
            //cout<<"175"<<endl;
            for(int j=0; j<col; j++)
            matrix[i][j] = 0;
        }
        //cout<<"178"<<endl;
        //printMatrix(matrix, row, col);
    }

    void backTOnormalMatrix(T **addResult, Sparse *addRes, int addSize)
    {
            for(int i=0; i<addSize; i++)
            {

                if (addRes[i].data != 0) 
                {
                    int r = addRes[i].row;
                    int c = addRes[i].col;
                    addResult[r][c] = addRes[i].data;
                }
        
            }
    }
    void backTOnormalList(T **addResult, node *addHead, int size)
    {
        //cout<<"208"<<endl;
        //cout<<size<<endl;
        node *temp = addHead;
        int i=0;
        while(i<size)
        {
            //cout<<"212"<<endl;
            if(temp->data != 0)
            {
                //cout<<"215"<<endl;
                int r = temp->row;;
                int c = temp->col;
                addResult[r][c] = temp->data;
                i++;
                
            }
            temp = temp->next;
        }
        //cout<<"221"<<endl;
                
    }

    void addMatrix(Sparse* mat1, Sparse* mat2, int row, int col, int len1, int len2) 
    {
        // Allocate memory for the result Sparse struct array
        Sparse* addRes = new Sparse[len1 + len2];

        int addSize = 0;

        int i = 0, j = 0;
        while (i < len1 && j < len2) 
        {
            if (mat1[i].row == mat2[j].row && mat1[i].col == mat2[j].col) 
            {
                addRes[addSize].data = mat1[i].data + mat2[j].data;
                addRes[addSize].row = mat1[i].row;
                addRes[addSize].col = mat1[i].col;
                i++;
                j++;
                addSize++;
            } 
            else if ((mat1[i].row < mat2[j].row) || (mat1[i].row == mat2[j].row && mat1[i].col < mat2[j].col)) 
            {
                addRes[addSize].data = mat1[i].data;
                addRes[addSize].row = mat1[i].row;
                addRes[addSize].col = mat1[i].col;
                i++;
                addSize++;
            } 
            else if ((mat1[i].row > mat2[j].row) || (mat1[i].row == mat2[j].row && mat1[i].col > mat2[j].col)) 
            {
                addRes[addSize].data = mat2[j].data;
                addRes[addSize].row = mat2[j].row;
                addRes[addSize].col = mat2[j].col;
                j++;
                addSize++;
            }
        }

        while (i < len1) 
        {
            addRes[addSize].data = mat1[i].data;
            addRes[addSize].row = mat1[i].row;
            addRes[addSize].col = mat1[i].col;
            i++;
            addSize++;
        }

        while (j < len2) 
        {
            addRes[addSize].data = mat2[j].data;
            addRes[addSize].row = mat2[j].row;
            addRes[addSize].col = mat2[j].col;
            j++;
            addSize++;
        }

        //cout << "addition result:" << endl;
        // for (int i = 0; i < addSize; i++)
        //     cout << addRes[i].row << " " << addRes[i].col << " " << addRes[i].data << endl;
        

        T **addResult = createMatrix(row, col);
        initiliseMatrix(addResult, row, col);
        backTOnormalMatrix(addResult, addRes, addSize);
        printMatrix(addResult, row, col);
    }


    void addList(node* a, node* b, int row, int col)
    {
        
        int addSize = 0;
        node* addHead = new node;
        node* p = a;
        node* q = b;
        while (p!=NULL && q!=NULL)
        {
            if (p->row == q->row && p->col == q->col)
            {
                int r = p->row;
                int c = p->col;
                T res = p->data + q->data;
                create_node(&addHead, r, c, res);
                p = p->next;
                q = q->next;
                addSize++;
            }
            else if ((p->row < q->row) || (p->row == q->row && p->col < q->col))
            {
                int r = p->row;
                int c = p->col;
                T res = p->data;
                create_node(&addHead, r, c, res);
                p = p->next;
                addSize++;
            }
            else if ((p->row > q->row) || (p->row == q->row && p->col > q->col))
            {
                int r = q->row;
                int c = q->col;
                T res = q->data;
                create_node(&addHead, r, c, res);
                q = q->next;
                addSize++;
            }
        }

        while (p!=NULL)
        {
            create_node(&addHead, p->row, p->col, p->data);
            p = p->next;
            addSize++;
        }
        while (q!=NULL)
        {
            create_node(&addHead, q->row, q->col, q->data);
            q = q->next;
            addSize++;
        }

        //cout << "addition result:" << endl;
        //printList(addHead);

        T **addResult = createMatrix(row, col);
        initiliseMatrix(addResult, row, col);
        backTOnormalList(addResult, addHead,addSize);
        printMatrix(addResult, row, col);
    }

    void transposeList(node* a, int row, int col)
    {
        //cout<<"354"<<endl;
        node* transposeHead = new node;
        

        int k=0;
        for(int j=0; j<col; j++)
        {
            node* p = a;
            while(p!=NULL)
            {
                if(p->col == j)
                {
                    //cout<<"366";
                    int r = p->col;
                    int c = p->row;
                    T data = p->data;;
                    create_node(&transposeHead, r, c, data);
                    k++;
                    
                }
                p = p->next;
            }
            
        }

        //cout  << endl;
        //printList(transposeHead);

        T **transposeResult = createMatrix(col, row);
        initiliseMatrix(transposeResult,col, row);
        backTOnormalList(transposeResult, transposeHead, k);
        //cout<<"Transpose of matrix:"<<endl;
        printMatrix(transposeResult, col, row);
    }
    void transposeMatrix(Sparse *matrix, int row, int col, int length)
    {
        //cout<<"358"<<endl;
        //cout<<length<<endl;
        Sparse *transposeRes = new Sparse[length];
        int k = 0;
        for (int j = 0; j < col; j++) 
        {
            for (int i = 0; i < length; i++) 
            {
                if (matrix[i].col == j) 
                {
                    transposeRes[k].row = matrix[i].col;
                    transposeRes[k].col = matrix[i].row;
                    transposeRes[k].data = matrix[i].data;
                    k++;
                }
            }
        }


        //cout << "transpose result:" << endl;
        // for (int i = 0; i < k; i++)
        //     cout << transposeRes[i].row << " " << transposeRes[i].col << " " << transposeRes[i].data << endl;


        //if(ds=1 && op==2)
        //{
            T **transposeResult = createMatrix(col, row);
            initiliseMatrix(transposeResult, col, row);
            backTOnormalMatrix(transposeResult, transposeRes,length);
            //cout<<"Transpose of matrix:"<<endl;
            printMatrix(transposeResult, col, row);
    // }
    }

    void mulMatrix(Sparse *mat1, int r1, int c1, int len1, Sparse *mat2, int c2, int r2, int len2)
    {

        for (int i = 0; i < len2; i++)
        {
            int temp = mat2[i].row;
            mat2[i].row = mat2[i].col;
            mat2[i].col = temp;
        }

        // Initialize the result matrix
        int maxResultSize = len1 * len2;
        Sparse* mulRes = new Sparse[maxResultSize];
        int mulSize = 0;

        for (int i = 0; i < len1; i++)
        {
            int row1 = mat1[i].row;
            int col1 = mat1[i].col;
            T v1 = mat1[i].data;

            for (int j = 0; j < len2; j++)
            {
                int row2 = mat2[j].row;
                int col2 = mat2[j].col;
                T v2 = mat2[j].data;

                if (col1 == col2)
                {
                    T temp = v1 * v2;

                    // Search for the same row and column in the result matrix
                    bool found = false;
                    for (int k = 0; k < mulSize; k++)
                    {
                        if (mulRes[k].row == row1 && mulRes[k].col == row2)
                        {
                            // If found, update the value
                            mulRes[k].data += temp;
                            found = true;
                            break;
                        }
                    }

                    // If not found, add a new entry
                    if (!found)
                    {
                        mulRes[mulSize].row = row1;
                        mulRes[mulSize].col = row2;
                        mulRes[mulSize].data = temp;
                        mulSize++;
                    }
                }
            }
        }
            
        //     cout << "multiplication result:" << endl;
        // for (int i = 0; i < mulSize; i++)
        //     cout << mulRes[i].row << " " << mulRes[i].col << " " << mulRes[i].data << endl;



        int row = r1;
        int col = r2;

        T **mulResult = createMatrix(row, col);
        initiliseMatrix(mulResult, row, col);
        backTOnormalMatrix(mulResult, mulRes, mulSize);
        //cout << "multiplication result compressed form:" << endl;

        printMatrix(mulResult, row, col);
    }

    void mulList(node *a, int r1, int c1, node *b, int c2, int r2)
    {
        node* mulHead = new node;
        //mulHead = NULL;

    
        node* ptr = b;
        int mulSize = 0;
        
        //transpose list b
        while(ptr != NULL)
        {
            int temp = ptr->row;
            ptr->row = ptr->col;
            ptr->col = temp;
            ptr = ptr->next;
        }
        // cout<<"priniting"<<endl;
        // printList(b);

        node *p = a;
        while(p!=NULL)
        {
            int row1 = p->row;
            int col1 = p->col;
            T v1 = p->data;

            node* q = b;
            while(q!=NULL)
            {
                int row2 = q->row;
                int col2 = q->col;
                T v2 = q->data;

                if (col1 == col2)
                {
                    //cout<<"col==col"<<endl;
                    T res = v1*v2;

                    // result matrix me same row and column search karte hai
                    node* temp = mulHead;
                    bool check = false;
                    while(temp != NULL)
                    {
                        //cout<<"inside temp != NULL"<<endl;
                        //cout<<p->row<<" "<<q->row<<endl;
                        //cout<<p->col<<" "<<q->col<<endl;
                        if (temp->row == row1 && temp->col == row2)
                        {
                            //cout<<"inside comp"<<endl;
                            check = true;
                            // agar mil gya toh update kardo
                            temp->data += res;
                            break;

                        }
                        temp = temp->next;
                    }

                    // agar kuch nahi mila toh new entry add kar dege
                    if (check == false)
                    {
                        //cout<<"inside check==false"<<endl;
                        //cout<<p->row<<" "<<q->row<<endl;
                        //cout<<p->col<<" "<<q->col<<endl;
                        create_node(&mulHead, row1, row2, res);
                        mulSize++;
                    }
                }
                q = q->next;
                //cout<<"moving q"<<endl;
            }
            p = p->next;
            //cout<<"moving p"<<endl;
        }
        //cout<<mulSize<<endl;

        //cout << "Result of list multiplication (compressed form):" << endl;
        //printList(mulHead);
        int row = r1;
        int col = r2;
        T **mulResult = createMatrix(row, col);
        initiliseMatrix(mulResult,row, col);
        backTOnormalList(mulResult, mulHead, mulSize);
        //cout<<"matrix:"<<endl;
        printMatrix(mulResult, row, col);
    }

};

int main()
{
    SparseOperation <float>s;
    int ds;
    int op;
    int size;
    int cap = 100;
    int r1, c1, r2, c2, s1=0, s2=0;
    // node* head1 = NULL; 
    // node* head2 = NULL;
    // //int** mat1, **mat2, **arr1, **arr2;
    // Sparse *mat1, *mat2;
    SparseOperation<float>::node* head1 = NULL; // Using the object's type to define a node
    SparseOperation<float>::node* head2 = NULL;

    SparseOperation<float>::Sparse* mat1; // Using the object's type to define a Sparse structure
    SparseOperation<float>::Sparse* mat2;

    //cout<<"Enter type of data structure u want: 1. Array 2. Linked List"<<endl;
    //int ds;
    cin>>ds;
    
    //cout<<"Enter operation u want: 1. Add 2. Transpose 3. Multiply"<<endl;
    //int op;
    cin>>op;

    if(ds==1)
    {
        //cout<<"Enter no of rows and columns of matrix 1"<<endl;
        cin>>r1>>c1;
        mat1 = new SparseOperation<float>::Sparse[cap];
        for(int i=0; i<r1; i++)
        {
            
            for(int j=0; j<c1; j++)
            {
                float element;
                cin>>element;
                if(element != 0)
                {
                    if(s1 == cap)
                    {
                        cap *= 2;
                        mat1 = (SparseOperation<float>::Sparse*)realloc(mat1, cap*sizeof(SparseOperation<float>::Sparse));
                    }
                    
                    mat1[s1].row = i;
                    mat1[s1].col = j;
                    mat1[s1].data = element;
                    s1++;
                }
            }
            //cout<<endl;
        }

        //cout << "Sparse Matrix 1:" << endl;
        // for (int i = 0; i < s1; i++)
        //     cout << mat1[i].row << " " << mat1[i].col << " " << mat1[i].data << endl;
        
        if(op == 1 || op == 3)
        {
            cap = 100;
            //cout<<"Enter no of rows and columns of matrix 2"<<endl;
            cin>>r2>>c2;

            mat2 = new SparseOperation<float>::Sparse[cap];
            for(int i=0; i<r2; i++)
            {
                for(int j=0; j<c2; j++)
                {
                    float element;
                    cin>>element;
                    if(element != 0)
                    {
                        if(s2 == cap)
                        {
                            cap *= 2;
                            mat2 = (SparseOperation<float>::Sparse*)realloc(mat2, cap*sizeof(SparseOperation<float>::Sparse));
                        }
                        
                        mat2[s2].row = i;
                        mat2[s2].col = j;
                        mat2[s2].data = element;
                        s2++;
                    }
                }
            }
            //cout<<endl;
        }
        // cout << "Sparse Matrix 2:" << endl;
        // for (int i = 0; i < s2; i++) 
        // {
        //     cout << mat2[i].row << " " << mat2[i].col << " " << mat2[i].data << endl;
        // }

    }
    else
    {
        // cout<<"else"<<endl;
        // cout<<"Enter no of rows and columns of matrix 1"<<endl;
        cin>>r1>>c1;

        for(int i=0; i<r1; i++)
        {
            for(int j=0; j<c1; j++)
            {
                float element;
                cin>>element;
                if(element != 0)
                {
                    s.create_node(&head1, i, j, element);
                    s1++;
                }
            }
        }
        // cout<<"list 1"<<endl;
        // printList(head1);

        if(op == 1 || op == 3)
        {
           // cout<<"Enter no of rows and columns of matrix 2"<<endl;
            cin>>r2>>c2;
            for(int i=0; i<r2; i++)
            {
                for(int j=0; j<c2; j++)
                {
                    float element;
                    cin>>element;
                    if(element != 0)
                    {
                        s.create_node(&head2, i, j, element);
                        s2++;
                    }
                }
            }
            // cout<<"list 2"<<endl;
            // printList(head2);
         }
    }

    if(ds == 1 && op == 1)
    {

        s.addMatrix(mat1, mat2, r1, c1, s1, s2);
    }
    else if(ds == 2 && op == 1)
    {
        s.addList(head1, head2, r1, c1);
    }

    else if(ds == 1 && op == 2)
    {
        s.transposeMatrix(mat1, r1, c1, s1);
    }
    else if(ds == 2 && op == 2)
    {
        s.transposeList(head1, r1, c1);
    }

    else if(ds==1 && op == 3)
    {

        s.mulMatrix(mat1, r1, c1, s1, mat2, c2, r1, s2);

    }
    else if(ds == 2 && op == 3)
    {
        s.mulList(head1, r1, c1, head2, r2, c2);
    }

}





