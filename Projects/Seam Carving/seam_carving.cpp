#include <opencv2/opencv.hpp>
#include<iostream>
#include<cmath>
#include<algorithm>
using namespace std;
using namespace cv;


// Function to extract RGB values in rgb_matrix
void extractRGB(Mat &test, Mat &rgb_matrix, int height_r, int width_c)
{
    for(int r=0; r<height_r; r++)
        {
            for(int c=0; c<width_c; c++)
             {
                Vec3b rgb = test.at<Vec3b>(r, c);
                int red = rgb[2];
                int green = rgb[1];
                int blue = rgb[0];

                rgb_matrix.at<Vec3b>(r, c) = Vec3b(red, green, blue); 
            }
        }
}

// Function to find energy of every pixel and store it in 2D energy matrix 'a'
void findEnergyMatrix(int **a, Mat &rgb_matrix, int height_r, int width_c)
{
    for(int r=0; r<height_r; r++)
        {
            for(int c=0; c<width_c; c++)
            {

                Vec3b energyx_1 = rgb_matrix.at<Vec3b>(r, (c-1+width_c)%width_c);
                Vec3b energyx_2 = rgb_matrix.at<Vec3b>(r, ( c+1+width_c)%width_c);

                int dif_rx = energyx_1[0] - energyx_2[0];
                int dif_gx = energyx_1[1] - energyx_2[1];
                int dif_bx = energyx_1[2] - energyx_2[2];

                int pow_rx = pow(dif_rx, 2);
                int pow_bx = pow(dif_bx,2);
                int pow_gx = pow(dif_gx, 2);
                
                int horizontal_rgb = pow_rx + pow_gx + pow_bx;

                Vec3b energyy_1 = rgb_matrix.at<Vec3b>((r-1+height_r)%height_r, c);
                Vec3b energyy_2 = rgb_matrix.at<Vec3b>(( r+1+height_r)%height_r, c);

                int dif_ry = energyy_1[0] - energyy_2[0];
                int dif_gy = energyy_1[1] - energyy_2[1];
                int dif_by = energyy_1[2] - energyy_2[2];

                int pow_ry = pow(dif_ry, 2);
                int pow_by = pow(dif_by,2);
                int pow_gy = pow(dif_gy, 2);

                int vertical_rgb = pow_ry + pow_gy + pow_by;
            
                int add_rgb = horizontal_rgb + vertical_rgb;
                int energy_gradient = sqrt(add_rgb);

                a[r][c] = energy_gradient;
            }
        }
}


//Function to print 2D matrix
void printMatrix(int **a, int height_r, int width_c)
{
    for(int i=0;i<height_r;i++)
    {
        for(int j=0;j<width_c;j++)
        {
            cout<<a[i][j]<<" ";
        }
        cout<<endl;
        
    }
}


//////////////////////////////////////////////////////////////////////////////////////////


//Function to apply DP on energy matrix horizontally
void dpVertical(int **a, int height_r, int width_c)
{
    for(int r=1; r<height_r; r++)
        {
            for(int c=0; c<width_c;c++)
            {
                if(c==0)
                {
                    a[r][c] = a[r][c] + min(a[r-1][c], a[r-1][c+1]);
                }

                if(c== width_c-1)
                {
                    a[r][c] =  a[r][c] + min(a[r-1][c], a[r-1][c-1]);
                }
                else
                {
                    a[r][c] =  a[r][c] + min({a[r-1][c-1], a[r-1][c], a[r-1][c+1]});
                }
            }
        }
}

//Function to calculate seam array to get min cost path vertically
void calculateSeamVertical(int *seam, int **a, int height_r, int width_c)
{
    //Calculating index of min cost in last row
    int j, index, min;
    min = INT_MAX;

    for(j=0;j<width_c;j++)
    {
        if(a[height_r-1][j] < min)
        {
            min = a[height_r-1][j];
            index = j;
        }
    }
    seam[height_r-1] = index;

    //Calculating min cost index of remaining rows
    for(int r=height_r-2;r>=0;r--)
    {
        int min = INT_MAX;

        int c=index;

        if(c==0)
        {
            if(a[r][c]<a[r][c+1])
            {
                min = a[r][c];
                index = c;
            }
            else
            {
                min = a[r][c+1];
                index = c+1;
            }
        }
        else if(c==width_c-1)
        {
            if (a[r][c-1]<a[r][c])
            {
                min = a[r][c-1];
                index = c-1;
            }
            else
            {
                min = a[r][c];
                index = c;
            }
        }
        else
        {
            int j=c-1;
            int i=0;
            while(i!=3 && j<=c+1)
            {
                if(a[r][j]<min)
                {
                    min = a[r][j];
                    index = j;
                }
                i++;
                j++;
            }
        }
        seam[r] = index;
    }
}

//FUnction to change rgb value of min cost pixel to 0,0,255 vertically
void showingSeamVertical(Mat &test, int *seam, int height_r)
{
    for(int r=0;r<height_r; r++)
    {   
        int c = seam[r];

        Vec3b &change_rgb = test.at<Vec3b>(r, c);
            change_rgb[0] = 255;
            change_rgb[1] = 0;
            change_rgb[2] = 0;
    } 
}

//Function to shift pixels to remove min seam horizontally
void shiftPixelVertical(int *seam, Mat &test, int height_r, int width_c)
{
    for(int i=0;i<height_r; i++)
    {
        for(int j = seam[i]; j<width_c - 1 ;j++)
        {
            test.at<Vec3b>(i, j) = test.at<Vec3b>(i, j+1);
        }
    }
}


/////////////////////////////////////////////////////////////////////////////////////////////////
            
//Function to apply DP on energy matrix vertically
void dpHorizontal(int **a, int height_r, int width_c)
{
    for(int c=1; c<width_c; c++)
    {
        for(int r=0; r<height_r;r++)
        {   
            if(r==0)
            {
                a[r][c]  = a[r][c] + min(a[r][c-1], a[r+1][c-1]);
            }
            else if(r == height_r-1)
            {
                a[r][c]  =  a[r][c] + min(a[r][c-1], a[r-1][c-1]);
            }
            else
            {
                a[r][c]  =  a[r][c] + min(a[r+1][c-1], min(a[r][c-1], a[r-1][c-1]));
            }   
        }
    }
}

//Function to calculate seam array to get min cost path horizontally
void calculateSeamHorizontal(int *seam, int **a, int height_r, int width_c)
{
    //Calculating index of min cost in last column
    int index, j;
    int min = INT_MAX;

    for(j=0;j<height_r;j++)
    {
        if(a[j][width_c-1] < min)
        {
            min = a[j][width_c-1];
            index = j;
        }
    }
    seam[width_c-1] = index;

    //Calculating min cost index of remaining column
    for(int c=width_c-2;c>=0;c--)
    {
        int min = INT_MAX;
        int r=index;
        if(r==0)
        {
            if(a[r][c-1]<a[r+1][c-1])
            {
                min = a[r][c-1];
                index = r;
            }
            else
            {
                min = a[r+1][c-1];
                index = r+1;
            }
        }
        else if(r==height_r-1)
        {
            if (a[r][c-1]<a[r-1][c-1])
            {
                min = a[r][c-1];
                index = r;
            }
            else
            {
                min = a[r-1][c-1];
                index = r-1;
            }
        }
        else
        {
            int j=r-1;
            int i=0;
            while(i!=3 && j<=r+1)
            {
                if(a[j][c]<min)
                {
                    min = a[j][c];
                    index = j;
                }
                    i++;
                    j++;
            }
        }
        seam[c] = index;
    }

}

//Function to change rgb value of min cost pixel to 0,0,255 horizontally
void showingSeamHorizontal(Mat &test, int *seam, int width_c)
{
    for(int c=0;c<width_c; c++)
    {   //cout<<"fucked"<<i<<"   ";
        int r = seam[c];
        //int r = i;
        Vec3b &change_rgb = test.at<Vec3b>(r, c);
        change_rgb[0] = 0;
        change_rgb[1] = 255;
        change_rgb[2] = 0;
    } 
}

//Function to shift pixels to remove min seam vertically
void shiftPixelHorizontal(int *seam, Mat &test, int height_r, int width_c)
{
     for(int i=0;i<width_c; i++)
    {
        for(int j = seam[i]; j<height_r-1;j++)
        {
            test.at<Vec3b>(j, i) = test.at<Vec3b>(j+1, i);
        }
    }
}


int main(int argc, char** argv)
{
    Mat test = imread(argv[1]);
    int height_r = test.rows;
    cout<<"Image height: "<<height_r<<endl;
    int width_c = test.cols;
    cout<<"Image width: "<<width_c<<endl;


    //Checking if image is loading successfully or not
    if(test.empty())
    {
        cerr<<"gazab topibazz aadmi ho"<<endl;
        return 0;
    }
    
    // reading heigth and width to modifiy input image
    cout<<"Enter the width and height you want to remove: "<<endl;
    int height, width;
    cin>>width>>height;

    //Defining a matrix to store RGB values 
    Mat rgb_matrix(height_r, width_c, CV_8UC3);

    //Initilizing a 2D matrix dynamically (double pointer) to store energy matrix
    int **a = new int*[height_r];
    // Allocate memory for each row
    for (int i = 0; i < height_r; i++) 
    {
        a[i] = new int[width_c];
    }   

    //***********************************VERTICAL SEAMING***************************************

    for(int c=0; c<width; c++)
    {
        // cout<<"vertical"<<endl;
        width_c = test.cols;
        
        // Extracting RGB values from image and storing it in rgb_matrix for futher processing
        extractRGB(test, rgb_matrix, height_r, width_c);

        //Finding Energy matrix 'a'
        findEnergyMatrix(a, rgb_matrix, height_r, width_c);

        //Finding a single seam from top to bottom in vertical direction WITH ONE PIXEL IN EACH ROW
        dpVertical(a, height_r, width_c);

        //printMatrix(a, height_r, width_c);

        //Initilizing seam array to store index of min cost pixel
        int* seam = new int[height_r];

        //calculating min cost index of a seam 
        calculateSeamVertical(seam, a, height_r, width_c);

        //Making seam visible in red colour
        showingSeamVertical(test, seam, height_r);

        //Showing operation on image  
        imshow("hy",test);
        waitKey(1);

        //Shifting pixels to reduce image in horizontally
        shiftPixelVertical(seam, test, height_r, width_c);
        
        //Reducing size of image horizontally
        test.cols--;
    }
    width_c = test.cols;
    cout<<"width: "<<width_c<<endl;
    
    //***********************************HORIZONTAL SEAMING***************************************
    
    for(int r=0; r<height; r++)
    {
        // cout<<"horizontal"<<endl;
        
        height_r = test.rows;

        extractRGB(test, rgb_matrix, height_r, width_c);
    
        findEnergyMatrix(a, rgb_matrix, height_r, width_c);

        dpHorizontal(a, height_r, width_c);

        int* seam = new int[width_c];

        calculateSeamHorizontal(seam, a, height_r, width_c);

        showingSeamHorizontal(test, seam, width_c);

        imshow("hy",test);
        waitKey(1);

        shiftPixelHorizontal(seam, test, height_r, width_c);
        
        test.rows--;
    }

    //Displaying modified image height and width
    cout<<"New image height: "<<height_r<<endl;
    cout<<"New image width: "<<width_c<<endl;

    //Displaying modified image
    imshow("hy", test);
    waitKey(2000);

    //Saving modified image in system
    imwrite("output2.jpeg", test);
}
