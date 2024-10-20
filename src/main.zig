const std = @import("std");
const time = @import("Utils/Time.zig");
const RSA = @import("RSA.zig");

const allocator = std.heap.page_allocator;
var cronometro = time.Cronometro.init();

pub const log_level: std.log.Level = .info;

pub fn main() !void {

    cronometro.start();
    
    const keys = try RSA.getKeys(allocator, 300, 30);
    std.debug.print("Generating keys took: {} ms\n", .{cronometro.elapsedTime()});

    const messaggio = "ciao come va"[0..];

    const mes = try RSA.cryptMessage(allocator, messaggio, keys[0]);
    defer allocator.free(mes);

    std.log.info("Messaggio criptato: {}\n", .{mes});
}
