const std = @import("std");

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

