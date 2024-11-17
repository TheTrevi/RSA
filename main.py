def gcdExtended(a, b): 
    # Base Case 
    if a == 0: 
        return b, 0, 1
             
    gcd, x1, y1 = gcdExtended(b % a, a) 
     
    # Update x and y using results of recursive call 
    print(y1, (b // a), x1)
    x = y1 - (b // a) * x1  # Use integer division here
    print(x,"ciaociao")
    y = x1 
     
    return gcd, x, y 

print(gcdExtended(5,8832))
