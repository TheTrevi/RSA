const std = @import("std");
const math = std.math;


pub fn mod_exp(base: u128, exp: u128, mod: u128) u128 {
    var result: u128 = 1;
    var b: u128 = base % mod;
    var e: u128 = exp;

    while (e > 0) {
        if ((e & 1) == 1) {
            result = (result * b) % mod;
        }
        b = (b * b) % mod;
        e >>= 1;
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

pub fn rsa_decrypt(encrypted: []const u128, d: u128, n: u128, alloc: std.mem.Allocator) ![]u8 {
    var slice = try alloc.alloc(u8, encrypted.len);
    var i: u32 = 0;

    for (encrypted) |c| {
    const decrypted_value = mod_exp(c, d, n);
    std.debug.print("c: {}, d: {}, n: {}, decrypted_value: {}\n", .{c, d, n, decrypted_value});

    if (decrypted_value > @as(u128,@intCast(255))) {
        return error.ValueOutOfRange; // Handle the error appropriately
    }

    slice[i] = @intCast(decrypted_value);
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
    
    const prova = extended_gcd(e, maximum);

    var d = prova[1];

    d = @mod(d, maximum);


    // const d:u128 = maximum-@as(u128,@intCast(prova));

    const publicKEY = [2]u128{e,key};
    const privateKEY  = [2]u128{@intCast(d), key};

    return [2][2]u128{publicKEY, privateKEY};
    
}



fn extended_gcd(a: i256, b: i256) [3]i256 {

    if (a == 0){
        return [_]i256{b,0,1};
    }

    const pp = extended_gcd(@mod(b,a), a);

    const temp0 = pp[2] - (@divTrunc(b, a) * pp[1]);
    return [_]i256{pp[0], temp0, pp[1]};

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

