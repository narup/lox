const std = @import("std");

pub fn main() !void {
    try print("Welcome to Lox. Version 0.01\n");

    var repl_active: bool = true;
    while (repl_active) {
        try print("lox> ");
        const input = try readInput();
        try printf("Output: {s}\n", .{input});

        repl_active = false;
    }
}

fn readInput() error{InputError}![]const u8 {
    return "this is fake input";
}

fn print(comptime msg: []const u8) !void {
    try printf(msg, .{});
}

fn printf(comptime format: []const u8, args: anytype) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print(format, args);
    try bw.flush();
}

fn play() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
