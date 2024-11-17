const std = @import("std");
const time = @import("Utils/Time.zig");
const RSA = @import("RSA.zig");

const allocator = std.heap.page_allocator;
var cronometro = time.Cronometro.init();

pub const log_level: std.log.Level = .info;

fn readInput() !?[]u8 {
    const in = std.io.getStdIn();
    var buf = std.io.bufferedReader(in.reader());

    // Get the Reader interface from BufferedReader
    var r = buf.reader();

    // Ideally we would want to issue more than one read
    // otherwise there is no point in buffering.
    var msg_buf: [4096]u8 = undefined;
    const msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');

    if (msg) | m | {
        std.debug.print("msg: {s}\n", .{m});
    }
    return msg ;
}


pub fn main() !void {

    cronometro.start();
    const keys = try RSA.getKeys(allocator, 300000, 120);
    std.log.debug("Generating keys took: {} ms\n", .{cronometro.elapsedTime()});
    std.log.debug("keys: {any}, {any}, {any}\n", .{keys[0][0], keys[1][1], keys[1][0]});

    // const messaggio = "come stai, tanto tempo fa"[0..];
    std.log.info("Messaggio da Criptare: ", .{});
    const messaggio = try readInput() orelse undefined;



    const mes = try RSA.rsa_encrypt(messaggio, keys[0][0], keys[0][1], allocator);
    defer allocator.free(mes);

    std.log.info("Messaggio criptato: {any}\n", .{mes});

    const chiaro = try RSA.rsa_decrypt(mes, keys[1][0], keys[1][1], allocator);
    defer allocator.free(chiaro);

    std.log.info("Messaggio in chiaro: {s}\n", .{chiaro});

}
