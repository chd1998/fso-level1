
#include "fft.h"

void ComplexFFT(float *R, float *I, int N, int invert)
{
    int n, nn, i, j, m, cnt, inc, k;
    float tmpR, tmpI, WR, WI, Ri, Ii, Rj, Ij;
    
    // 原版本R[0]是数组大小，从R[1]开始是数据区域
    R--, I--;
    
    n = N, nn = n >> 1;
    for(j = 0, i = 0; i < n - 1; i++)   
    {  
        if(i < j)
        {  
            tmpR = R[j + 1], tmpI = I[j + 1];
            R[j + 1] = R[i + 1], I[j + 1] = I[i + 1];
            R[i + 1] = tmpR, I[i + 1] = tmpI;
        }
        m = n >> 1;
        while(j >= m)
        {
            j = j - m;
            m = m >> 1;
        } 
        j = j + m;
    }

    m = 1;
    // 1, 2, 4 级
    while(m < n)
    {
        /*
            m = 1: [1, 2], [3, 4], [5, 6], [7, 8] 4
            m = 2: [1, 3], [2, 4], [5, 7], [6, 8] 2
            m = 4: [1, 5], [2, 6], [3, 7], [4, 8] 1
         */
        //printf("M = %d\n", m);
        cnt = 0, inc = n / (m << 1);
        // inc: 4 2 1
        // m  : 1 2 4
        // W递增inc
        while(cnt < inc)
        {
            // m = 1: 1 3 5 7
            // m = 2: 1 5
            // m = 4: 1
            i = cnt * m * 2 + 1;
            // W[0, n]: inc
            // 计算m次 迭代inc次
            for(int t = 0; t < m; t++, i++)
            {
                j = i + m;
                k = t * inc;
                // printf("[%3d, %3d] W[%3d, %3d]\n", i, j, k, nn);
                k == 0 ? WR = 1.0, WI = 0.0: WR = cos(PI * k / nn), WI = -sin(PI * k / nn);
                if(invert) WI = - WI;
                //(R[i], I[i]) = (Ri, Ii) + W * (Rj, Ij)
                //(R[j], I[j]) = (Ri, Ii) - W * (Rj, Ij)
                Rj = R[j], Ij = I[j], Ri = R[i], Ii = I[i];
                R[i] = Ri + WR * Rj - WI * Ij, I[i] = Ii + WR * Ij + WI * Rj;
                R[j] = Ri - WR * Rj + WI * Ij, I[j] = Ii - WR * Ij - WI * Rj;
            }
            cnt++;
        }
        m = m << 1;
    }

    if (invert)
        for (i = 1; i <= n; i++)
            R[i] = R[i] / n, I[i] = I[i] / n;