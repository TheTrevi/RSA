const std = @import("std");
const math = std.math;


fn mod_exp(base: u128, exp: u128, mod: u128) u128 {
    var result: u128 = 1;
    var b: u128 = base % mod;
    var e: u128 = exp;

    while (e > 0) {
        if (e % 2 == 1) {
            result = (result * b) % mod;
        }
        b = (b * b) % mod;
        e = e / 2; // Integer division
    }
    return result;
}

    pub fn rsa_encrypt(message: []const u8, e: u128, n: u128, alloc: std.mem.Allocator) ![]u128 {

        var slice = try alloc.alloc(u128, message.len);
        var i:u32 = 0;
        for (message) |c| {
            slice[i] = mod_exp(@intCast(c), e, n);
            i += 1;
        }
        return slice;
    }

    pub fn rsa_decrypt(message: []const u128, e: u128, n: u128, alloc: std.mem.Allocator) ![]u128 {

    var slice = try alloc.alloc(u128, message.len);
    var i:u32 = 0;
    for (message) |c| {
        slice[i] = @intCast(mod_exp(c, e, n));
        i += 1;
    }
    return slice;
}




pub fn getKeys(allocator: std.mem.Allocator, n:u64, difference: u64) ![2][2]u128 {
    const rand = std.crypto.random;

    const primes = try getPrimes(allocator, n);
    defer allocator.free(primes);


    var firstPrime: u64 = undefined;
    var secondPrime: u64 = undefined;

    
    while (true){    
        firstPrime = rand.intRangeAtMost(u64, 0, primes.len-1);
        secondPrime = rand.intRangeAtMost(u64, firstPrime+1, primes.len-1);
        if (primes[secondPrime] - primes[firstPrime] > difference) break;
    }

    const key = primes[firstPrime] * primes[secondPrime];
    const maximum = (primes[firstPrime]-1) * (primes[secondPrime]-1);
    
    std.log.debug("firstPrime: {}, secondPrime: {}\n", .{primes[firstPrime],primes[secondPrime]});
    
    var e:u128 = 3;
    while (maximum%e == 0) {
        e += 2;
    }
    
    var prova = try extended_gcd(e, maximum);




    if (prova<0) prova *= -1;

    const d:u128 = maximum-@as(u128,@intCast(prova));

    const publicKEY = [2]u128{e,key};
    const privateKEY  = [2]u128{d, key};

    return [2][2]u128{publicKEY, privateKEY};
    
}




fn extended_gcd(a: i256, b: i256) !i256 {
    var x0: i256 = 1;
    var x1: i256 = 0;
    var y0: i256 = 0;
    var y1: i256 = 1;
    var a_temp = a;
    var b_temp = b;

    while (b_temp != 0) {
        const quotient = @divTrunc(a_temp , b_temp);
        const temp_b = b_temp;
        b_temp = @rem(a_temp , b_temp);
        a_temp = temp_b;

        const temp_x = x0 - quotient * x1;
        x0 = x1;
        x1 = temp_x;

        const temp_y = y0 - quotient * y1;
        y0 = y1;
        y1 = temp_y;
    }

    return x0;
}




pub fn getPrimes(allocator: std.mem.Allocator, n: u64) ![]u64 {
    var primes = try allocator.alloc(bool, @intCast(@as(usize, n+1)));
    defer allocator.free(primes);

    // Initialize vector with true
    for (primes[0..]) |*prime| {
        prime.* = true;
    }

    var p: u64 = 2;
    while (p * p <= n) {
        if (primes[@intCast(@as(usize,p))]) {
            var index: u64 = p * p;
            while (index <= n) {
                primes[@intCast(@as(usize, index))] = false;
                index += p;
            }
        }
        p += 1;
    }

    // Add numebrs based on booleans
    var result = try allocator.alloc(u64, n);
    var result_len: usize = 0;
    var i:u64 = 0;
    for (primes[0..n]) |is_prime| {
        if (is_prime and i >= 2) {
            result[result_len] = @intCast(@as(u64, i));
            result_len += 1;
        }
        i += 1;
    }

    return result[0..result_len];
}

