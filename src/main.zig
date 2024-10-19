const std = @import("std");
const time = @import("Utils/Time.zig");
const RSA = @import("RSA.zig");

const allocator = std.heap.page_allocator;
var cronometro = time.Cronometro.init();

pub const log_level: std.log.Level = .info;

pub fn main() !void {
    const n: u64 = 10000000;
    // const dif = 10000;
    cronometro.start();
    
    const primes = try RSA.getPrimes(allocator, n);
    defer allocator.free(primes);
    
    std.debug.print("Generating primes took: {} ms\n", .{cronometro.elapsedTime()});
}
