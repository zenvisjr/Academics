#include <iostream>
#include <algorithm>

using namespace std;

int mod = 1e9 + 7;

int main() 
{
    int n;
    cin>>n;

    int prices[n];


    for (int i=0; i<n; i++) 
    {
        cin>>prices[i];
    }

    // initialize dp and count array to 1
    int dp[n];
    int cnt[n];
    for (int i=0; i<n; i++) 
    {
        dp[i] = 1;
        cnt[i] = 1;
    }

    // calculating LIS length for every element in dp[] and counting the number of ways to achieve each LIS length in cnt[]

    int max_length = 1;
    
    for (int i=1; i<n; i++) 
    {
        for (int j=0; j<i; j++) 
        {
            if (prices[i] > prices[j]) 
            {
                if (dp[j]+1 > dp[i]) 
                {
                    dp[i] = dp[j] + 1;
                    cnt[i] = cnt[j];
                } 
                else if (dp[j] + 1 == dp[i]) 
                {
                    cnt[i] = (cnt[i] + cnt[j]) % mod;
                }
            }
        }
        //finding LIS
        max_length = max(max_length, dp[i]);
    }

    // finding number of LIS 
    int ans = 0;

    for (int i = 0; i<n; i++) 
    {
        if (dp[i] == max_length) 
        {
            ans = (ans + cnt[i]) % mod;
        }
    }

    cout<<ans<<endl;

    return 0;
}
