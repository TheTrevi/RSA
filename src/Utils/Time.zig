const std = @import("std");


pub const Cronometro = struct {

    startTime: i64 = 0,
    endTime: i64 = 0,

    pub fn init() Cronometro {
        return Cronometro{
            .startTime = 0,
            .endTime = 0,
        };
    }

    pub fn start(self: *Cronometro) void {
        self.startTime = std.time.milliTimestamp();
    }

    pub fn elapsedTime(self: *Cronometro) i64 {
        self.endTime = std.time.milliTimestamp();
        return self.endTime - self.startTime;
    }

};