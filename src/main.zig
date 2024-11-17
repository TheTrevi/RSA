const std = @import("std");
const time = @import("Utils/Time.zig");
const RSA = @import("RSA.zig");

const allocator = std.heap.page_allocator;
var cronometro = time.Cronometro.init();

pub const log_level: std.log.Level = .info;

pub fn main() !void {

    cronometro.start();
    const keys = try RSA.getKeys(allocator, 300, 30);
    std.log.debug("Generating keys took: {} ms\n", .{cronometro.elapsedTime()});
    std.log.debug("keys: {any}, {any}\n", .{keys[0][0], keys[1][1]});

    const messaggio = "come stai, tanto tempo fa"[0..];



    const mes = try RSA.rsa_encrypt(messaggio, keys[0][0], keys[0][1], allocator);
    defer allocator.free(mes);

    std.log.info("Messaggio criptato: {any}\n", .{mes});

    const chiaro = try RSA.rsa_decrypt(mes, keys[1][0], keys[1][1], allocator);
    defer allocator.free(chiaro);

    std.log.info("Messaggio in chiaro: {any}\n", .{chiaro});

}
