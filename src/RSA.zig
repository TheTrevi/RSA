const std = @import("std");
const math = std.math;


pub fn cryptMessage(allocator:std.mem.Allocator, msg: []const u8, keys: [2]u128) ![]u128 {
    var encrypt = try allocator.alloc(u128, msg.len);
    
    // converti ogni byte del messaggio in una grandezza numerica e applica RSA
    for (msg, 0..) |byte, i| {
        const value: u128 = @intCast(@as(u128, byte)); 
        encrypt[i] = math.pow(u128, value, keys[0]) % keys[1]; // cifratura RSA: c = m^e % n
    }
    return encrypt;
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
    
    var e = rand.intRangeAtMost(u128, 3, maximum-1);
    while (maximum%e == 0) {
        e = rand.intRangeAtMost(u128, 3, maximum-1);
    }
    
    var d: u128 = maximum+1;
    while (true) {
        if (d%e == 0) {break;}
        else d += maximum;
    }
    d = d/e;

    const publicKEY = [2]u128{e,key};
    const privateKEY  = [2]u128{d, key};

    return [2][2]u128{publicKEY, privateKEY};
    
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

