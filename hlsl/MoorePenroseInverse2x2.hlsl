// Andrew M. Cross (andrew.miah.cross@gmail.com)

void MoorePenrose_2x2(in float2x2 A, out float2x2 Q, out float2x2 R)
{
    const float tolerance = pow(10, -FLT_DIG);
    R = A;
            
    if (abs(R[1][0]) == 0)
    {
        return;
    }
            
    float r;
    if (abs(R._m00) >= abs(R._m10))
    {
        r = abs(R._m00) * sqrt(1 + pow(R._m10 / R._m00, 2));
    }
    else
    {
        r = abs(R._m10) * sqrt(1 + pow(R._m00 / R._m10, 2));
    }
                                    
    if (abs(r) < tolerance)
    {
        return;
    }
            
    float c = R._m00 / r;
    float s = R._m10 / r;
     
    float2x2 G;
    G._m00 = c;
    G._m11 = c;
    G._m01 = s;
    G._m10 = -s;

    R = mul(G, R);
    Q = transpose(G);
}
